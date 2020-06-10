locals {
  cluster_name                  = "test-eks-irsa"
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler"
  vpc_name                      = "k8s-vpc"
  bucket_name                   = "my-s3-bucket-for-logs"
  elb_certname                  = "elb-cert"
  elb_name                      = "foobar-terraform-elb"
  createbucket                  = true
  createeks                     = false
}
resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol = -1

    self        = true
    cidr_blocks = ["0.0.0.0/0"]

    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

resource "aws_volume_attachment" "ebs_att" {
  count        = var.count_vms
  device_name  = "/dev/sdh"
  volume_id    = element(aws_ebs_volume.awsvol.*.id, count.index)
  instance_id  = element(aws_instance.awsweb.*.id, count.index)
  force_detach = true
}

module "s3_bucket_for_logs" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  create_bucket = local.createbucket
  bucket        = local.bucket_name
  acl           = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true
  versioning = {
    enabled = true
  }
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  #enable_vpn_gateway   = true
  enable_dns_hostnames = true
  enable_dhcp_options  = true
  enable_dns_support   = true
  enable_ipv6          = true
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
  tags = {
    Terraform                          = "true"
    Environment                        = "dev"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}
resource "aws_instance" "awsweb" {


  count         = var.count_vms
  ami           = var.distro == "rhel77" ? lookup(var.rhelamis, var.region) : lookup(var.centosamis, var.region)
  subnet_id     = element(module.vpc.public_subnets, count.index)
  instance_type = "t2.large"
  key_name      = var.key_name
  tags = {
    Name = "${var.tag_prefix}-${count.index}"
  }

  user_data = var.distro == "rhel77" ? file("prep-rhel77.txt") : file("prep-centos7.txt")
}

resource "aws_ebs_volume" "awsvol" {
  count             = var.count_vms
  availability_zone = element(aws_instance.awsweb.*.availability_zone, count.index)
  size              = var.disk_sizegb
  depends_on        = [aws_instance.awsweb]
  tags = {
    Name = "${var.tag_prefix}-${count.index}"
  }
}
resource "aws_iam_server_certificate" "elb_cert" {
  name_prefix      = local.elb_certname
  certificate_body = file(var.elbcertpath)
  private_key      = file(var.private_key_path)

  lifecycle {
    create_before_destroy = true
  }
}
resource "null_resource" "provision" {
  count = var.count_vms

  triggers = {
    current_ec2_instance_id = element(aws_instance.awsweb.*.id, count.index)
    instance_number         = count.index + 1
  }

  provisioner "remote-exec" {
    connection {
      user        = var.distro == "rhel77" ? var.rheluser : var.centosuser
      private_key = file(var.private_key_path)
      host        = element(aws_instance.awsweb.*.public_dns, count.index)
      agent       = false
      timeout     = "120s"
    }

    inline = [
      "echo INSTANCE_NUMBER=${count.index + 1} && curl http://169.254.169.254/latest/user-data|sudo sh",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_instance.awsweb, aws_ebs_volume.awsvol, aws_volume_attachment.ebs_att]
}

resource "aws_elb" "bar" {
  name  = local.elb_name
  count = 1
  #availability_zones = element(aws_instance.awsweb.*.availability_zone,count.index)
  subnets = aws_instance.awsweb.*.subnet_id
  #security_groups = aws_instance.awsweb[count.index].security_groups.id


  access_logs {
    bucket   = local.bucket_name
    interval = 60
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = aws_iam_server_certificate.elb_cert.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  instances                   = aws_instance.awsweb.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "foobar-terraform-elb"
  }
  depends_on = [aws_instance.awsweb, aws_iam_server_certificate.elb_cert]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  create_eks      = local.createeks
  cluster_name    = local.cluster_name
  cluster_version = "1.16"
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  enable_irsa = true

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.medium"
      asg_desired_capacity = 1
      asg_max_size         = 5
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }
  ]
}
output "ami" {
  value = aws_instance.awsweb.*.id
}

output "zone" {
  value = aws_instance.awsweb.*.availability_zone
}

output "volumeid" {
  value = aws_ebs_volume.awsvol.*.id
}

output "address" {
  value = "${aws_instance.awsweb.*.public_dns}"
}

output "connect_as" {
  value = "ssh -i ${var.private_key_path} ${var.distro == "rhel77" ? var.rheluser : var.centosuser}@<<public_dns>>"
}

output "instance_ips" {
  value = aws_instance.awsweb.*.public_ip
}