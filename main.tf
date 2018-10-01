resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.awsvol.id}"
  instance_id  = "${aws_instance.awsweb.id}"
  force_detach = true
}

variable "max_availability_zones" {
  default = "2"
}

data "aws_availability_zones" "available" {}

resource "aws_instance" "awsweb" {
  ami                = "${lookup(var.rhelamis, var.region)}"
  availability_zones = ["${slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)}"]
  instance_type      = "t2.xlarge"

  associate_public_ip_address = "true"
  key_name                    = "${var.key_name}"

  tags {
    Name = "awsweb"
  }

  user_data = "${file("prep-rhel75.txt")}"
}

resource "aws_ebs_volume" "awsvol" {
  availability_zone = "${aws_instance.awsweb.availability_zone}"
  size              = 50
  depends_on        = ["aws_instance.awsweb"]
}

resource "null_resource" "provision" {
  provisioner "remote-exec" {
    connection {
      user = "ec2-user"
      host = "${aws_instance.awsweb.public_dns}"

      # The connection will use the local SSH agent for authentication.
      private_key = "${file(var.private_key_path)}"
    }

    inline = [
      "curl http://169.254.169.254/latest/user-data|sudo sh",
    ]
  }

  depends_on = ["aws_instance.awsweb", "aws_ebs_volume.awsvol", "aws_volume_attachment.ebs_att"]
}

output "ami" {
  value = "${aws_instance.awsweb.id}"
}

output "region" {
  value = "${aws_instance.awsweb.availability_zone}"
}

output "volumeid" {
  value = "${aws_ebs_volume.awsvol.id}"
}

output "address" {
  value = "${aws_instance.awsweb.public_dns}"
}
