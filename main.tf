
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
  version    = "2.66.0"
}

resource "aws_default_security_group" "default" {
  count  = lookup(var.eks_params, "createeks") == "false" && var.count_vms == "0" ? 0 : 1
  vpc_id = module.vpc.vpc_id
  /**
  ingress {
    protocol = -1

    self        = true
    cidr_blocks = formatlist("%s/32", aws_instance.awsweb.*.public_ip)

    from_port = 0
    to_port   = 0
  }
  ingress {
    protocol = -1

    self        = true
    cidr_blocks = [lookup(var.vpc_params, "vpc_cidr")]

    from_port = 0
    to_port   = 0
  }
  **/
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
module "vpc" {
  source     = "terraform-aws-modules/vpc/aws"
  create_vpc = lookup(var.eks_params, "createeks") == "false" && var.count_vms == "0" ? false : true
  name       = lookup(var.vpc_params, "vpc_name")
  cidr       = lookup(var.vpc_params, "vpc_cidr")

  azs                    = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets        = lookup(var.vpc_subnets, "vpc_private_subnets")
  public_subnets         = lookup(var.vpc_subnets, "vpc_public_subnets")
  enable_nat_gateway     = lookup(var.vpc_params, "enable_nat_gateway")
  single_nat_gateway     = lookup(var.vpc_params, "single_nat_gateway")
  one_nat_gateway_per_az = lookup(var.vpc_params, "one_nat_gateway_per_az")
  enable_vpn_gateway     = lookup(var.vpc_params, "enable_vpn_gateway")
  enable_dns_hostnames   = lookup(var.vpc_params, "enable_dns_hostnames")
  enable_dhcp_options    = lookup(var.vpc_params, "enable_dhcp_options")
  enable_dns_support     = lookup(var.vpc_params, "enable_dns_support")
  enable_ipv6            = lookup(var.vpc_params, "enable_ipv6")
  public_subnet_tags = {
    "kubernetes.io/cluster/${lookup(var.eks_params, "cluster_name")}" = "shared"
    "kubernetes.io/role/elb"                                          = "1"
  }
  tags = {
    Terraform                          = "true"
    Environment                        = lookup(var.vpc_params, "environment_tag")
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
  count            = var.count_vms == "0" ? 0 : 1
  name_prefix      = lookup(var.s3_elb_params, "elb_certname")
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

  depends_on = [aws_instance.awsweb, aws_ebs_volume.awsvol, aws_volume_attachment.ebs_att, aws_default_security_group.default]
}
resource "aws_volume_attachment" "ebs_att" {
  count        = var.count_vms
  device_name  = "/dev/sdh"
  volume_id    = element(aws_ebs_volume.awsvol.*.id, count.index)
  instance_id  = element(aws_instance.awsweb.*.id, count.index)
  force_detach = true
}

resource "aws_elb" "bar" {
  name  = lookup(var.s3_elb_params, "elb_name")
  count = var.count_vms == "0" ? 0 : 1
  #availability_zones = element(aws_instance.awsweb.*.availability_zone,count.index)
  subnets = aws_instance.awsweb.*.subnet_id
  #security_groups = aws_instance.awsweb[count.index].security_groups.id


  access_logs {
    bucket   = lookup(var.s3_elb_params, "bucket_name")
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
    ssl_certificate_id = aws_iam_server_certificate.elb_cert.0.arn
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
    Name = lookup(var.s3_elb_params, "elb_name")
  }
  depends_on = [aws_instance.awsweb, aws_iam_server_certificate.elb_cert]
}
module "s3_bucket_for_logs" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  create_bucket = var.count_vms == "0" ? false : true
  bucket        = lookup(var.s3_elb_params, "bucket_name")
  acl           = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true
  versioning = {
    enabled = true
  }
}

data "aws_eks_cluster" "cluster" {
  name  = module.eks-cluster.cluster_id
  count = lookup(var.eks_params, "createeks") == "false" ? 0 : 1
}

data "aws_eks_cluster_auth" "cluster" {
  name  = module.eks-cluster.cluster_id
  count = lookup(var.eks_params, "createeks") == "false" ? 0 : 1
}

provider "kubernetes" {
  host                   = length(data.aws_eks_cluster.cluster) == 0 ? "" : element(data.aws_eks_cluster.cluster.*.endpoint, length(data.aws_eks_cluster.cluster))
  cluster_ca_certificate = length(data.aws_eks_cluster.cluster) == 0 ? "" : base64decode(element(data.aws_eks_cluster.cluster.*.certificate_authority.0.data, length(data.aws_eks_cluster.cluster)))
  token                  = length(data.aws_eks_cluster.cluster) == 0 ? "" : element(data.aws_eks_cluster_auth.cluster.*.token, length(data.aws_eks_cluster_auth.cluster))
  load_config_file       = false
  version                = "~> 1.11"
}

module "eks-cluster" {
  source                    = "terraform-aws-modules/eks/aws"
  create_eks                = lookup(var.eks_params, "createeks")
  cluster_name              = lookup(var.eks_params, "cluster_name")
  cluster_version           = lookup(var.eks_params, "cluster_version")
  subnets                   = module.vpc.private_subnets
  vpc_id                    = module.vpc.vpc_id
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  enable_irsa = lookup(var.eks_params, "enable_irsa")
  /**
  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.medium"
      asg_desired_capacity = 1
      asg_max_size         = 5
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${lookup(var.eks_params, "cluster_name")}"
          "propagate_at_launch" = "true"
          "value"               = "true"
        }
      ]
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t2.medium"
      asg_desired_capacity = 2
      asg_max_size         = 5
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${lookup(var.eks_params, "cluster_name")}"
          "propagate_at_launch" = "true"
          "value"               = "true"
        }
      ]
    }
  ]
**/
  worker_groups_launch_template = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      asg_desired_capacity = 2
      asg_max_size         = 5
      public_ip            = false
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${lookup(var.eks_params, "cluster_name")}"
          "propagate_at_launch" = "true"
          "value"               = "true"
        }
      ]
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t2.medium"
      asg_desired_capacity = 2
      asg_max_size         = 5
      public_ip            = false
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${lookup(var.eks_params, "cluster_name")}"
          "propagate_at_launch" = "true"
          "value"               = "true"
        }
      ]
    },
    {
      name                 = "worker-group-3"
      instance_type        = "t2.micro"
      asg_desired_capacity = 2
      asg_max_size         = 5
      public_ip            = false
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${lookup(var.eks_params, "cluster_name")}"
          "propagate_at_launch" = "true"
          "value"               = "true"
        }
      ]
    },
  ]

}
/**
module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 2.0"

  create_role = true

  role_name = "role-with-oidc"

  tags = {
    Role = "role-with-oidc"
  }

  provider_url = module.eks-cluster.cluster_oidc_issuer_url

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]
}
**/
module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "cluster-autoscaler"
  provider_url                  = replace(module.eks-cluster.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${lookup(var.eks_params, "k8s_service_account_namespace")}:${lookup(var.eks_params, "k8s_service_account_name")}}"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks-cluster.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks-cluster.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
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