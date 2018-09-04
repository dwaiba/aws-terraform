resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.pegavol.id}"
  instance_id  = "${aws_instance.pegaweb.id}"
  force_detach = true
}

resource "aws_instance" "pegaweb" {
  ami                         = "ami-c86c3f23"
  availability_zone           = "eu-central-1a"
  instance_type               = "t2.xlarge"
  associate_public_ip_address = "true"
  key_name                    = "${var.key_name}"

  tags {
    Name = "pega"
  }

  user_data = "${file("prep-rhel75.txt")}"
}

resource "aws_ebs_volume" "pegavol" {
  availability_zone = "eu-central-1a"
  size              = 50
}

resource "null_resource" "provision" {
  provisioner "remote-exec" {
    connection {
      user = "ec2-user"
      host = "${aws_instance.pegaweb.public_dns}"

      # The connection will use the local SSH agent for authentication.
      private_key = "${file(var.private_key_path)}"
    }

    inline = [
      "curl http://169.254.169.254/latest/user-data|sudo sh",
    ]
  }

  depends_on = ["aws_instance.pegaweb", "aws_ebs_volume.pegavol", "aws_volume_attachment.ebs_att"]
}

output "address" {
  value = "${aws_instance.pegaweb.public_dns}"
}
