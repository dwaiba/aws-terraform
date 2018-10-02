resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.awsvol.id}"
  instance_id  = "${aws_instance.awsweb.id}"
  force_detach = true
}

resource "aws_instance" "awsweb" {
  ami = "${lookup(var.centosamis, var.region)}"

  /**
                          availability_zone = "${var.region}a"
                          **/
  instance_type = "t2.xlarge"

  associate_public_ip_address = "true"
  key_name                    = "${var.key_name}"

  tags {
    Name = "awsweb"
  }

  user_data = "${file("prep-centos7.txt")}"
}

resource "aws_ebs_volume" "awsvol" {
  availability_zone = "${aws_instance.awsweb.availability_zone}"
  size              = 50
  depends_on        = ["aws_instance.awsweb"]
}

resource "null_resource" "provision" {
  provisioner "remote-exec" {
    connection {
      user        = "centos"
      private_key = "${file(var.private_key_path)}"
      host        = "${aws_instance.awsweb.public_dns}"
      agent       = false
      timeout     = "10s"
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

output "zone" {
  value = "${aws_instance.awsweb.availability_zone}"
}

output "volumeid" {
  value = "${aws_ebs_volume.awsvol.id}"
}

output "volumearn" {
  value = "${aws_ebs_volume.awsvol.arn}"
}

output "address" {
  value = "${aws_instance.awsweb.public_dns}"
}

output "connect" {
  value = "ssh -i ${file(var.private_key_path)} centos@${aws_instance.awsweb.public_dns}"
}
