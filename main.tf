/**
resource "aws_vpc" "mainvpc" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.mainvpc.id}"

  ingress {
    protocol = -1

        self      = true
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
**/

resource "aws_volume_attachment" "ebs_att" {
  count        = "${var.count_vms}"
  device_name  = "/dev/sdh"
  volume_id    = "${element(aws_ebs_volume.awsvol.*.id, count.index)}"
  instance_id  = "${element(aws_instance.awsweb.*.id, count.index)}"
  force_detach = true
}

resource "aws_instance" "awsweb" {
  /**
                ami = "${lookup(var.centosamis, var.region)}"


                                          availability_zone = "${var.region}a"
                                          **/
  count = "${var.count_vms}"

  ami = "${var.distro == "rhel75" ? lookup(var.rhelamis, var.region) : lookup(var.centosamis, var.region)}"

  instance_type = "t2.xlarge"

  associate_public_ip_address = "true"
  key_name                    = "${var.key_name}"

  tags {
    "Name" = "${var.tag_prefix}-${count.index}"
  }

  user_data = "${var.distro == "rhel75" ? file("prep-rhel75.txt") : file("prep-centos7.txt")}"
}

resource "aws_ebs_volume" "awsvol" {
  count             = "${var.count_vms}"
  availability_zone = "${element(aws_instance.awsweb.*.availability_zone, count.index)}"
  size              = "${var.disk_sizegb}"
  depends_on        = ["aws_instance.awsweb"]

  tags {
    "Name" = "${var.tag_prefix}-${count.index}"
  }
}

resource "null_resource" "provision" {
  count = "${var.count_vms}"

  triggers {
    current_ec2_instance_id = "${element(aws_instance.awsweb.*.id, count.index)}"
    instance_number         = "${count.index + 1}"
  }

  provisioner "remote-exec" {
    connection {
      user        = "${var.distro == "rhel75" ? var.rheluser : var.centosuser}"
      private_key = "${file(var.private_key_path)}"
      host        = "${element(aws_instance.awsweb.*.public_dns, count.index)}"
      agent       = false
      timeout     = "10s"
    }

    inline = [
      "echo INSTANCE_NUMBER=${count.index + 1} && curl http://169.254.169.254/latest/user-data|sudo sh",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_instance.awsweb", "aws_ebs_volume.awsvol", "aws_volume_attachment.ebs_att"]
}

output "ami" {
  value = "${aws_instance.awsweb.*.id}"
}

output "zone" {
  value = "${aws_instance.awsweb.*.availability_zone}"
}

output "volumeid" {
  value = "${aws_ebs_volume.awsvol.*.id}"
}

output "address" {
  value = "${aws_instance.awsweb.*.public_dns}"
}

output "connect_as" {
  value = "ssh -i ${var.private_key_path} ${var.distro == "rhel75" ? var.rheluser : var.centosuser}@<<public_dns>>"
}
