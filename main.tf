variable "instance-count" {
  default = "2"
}

resource "aws_volume_attachment" "ebs_att" {
  count        = "${var.instance-count}"
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.awsvol.id}"
  instance_id  = "${aws_instance.awsweb.id}"
  force_detach = true
}

resource "aws_instance" "awsweb" {
  /**
          ami = "${lookup(var.centosamis, var.region)}"


                                    availability_zone = "${var.region}a"
                                    **/
  count = "${var.instance-count}"

  ami = "${var.distro == "rhel75" ? lookup(var.rhelamis, var.region) : lookup(var.centosamis, var.region)}"

  instance_type = "t2.xlarge"

  associate_public_ip_address = "true"
  key_name                    = "${var.key_name}"

  tags {
    "Name" = "instance-${count.index}"
  }

  user_data = "${var.distro == "rhel75" ? file("prep-rhel75.txt") : file("prep-centos7.txt")}"
}

resource "aws_ebs_volume" "awsvol" {
  count             = "${var.instance-count}"
  availability_zone = "${aws_instance.awsweb.availability_zone}"
  size              = "${var.disk_sizegb}"
  depends_on        = ["aws_instance.awsweb"]
}

resource "null_resource" "provision" {
  provisioner "remote-exec" {
    connection {
      user        = "${var.distro == "rhel75" ? var.rheluser : var.centosuser}"
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
  value = "ssh -i ${var.private_key_path} ${var.distro == "rhel75" ? var.rheluser : var.centosuser}@${aws_instance.awsweb.public_dns}"
}
