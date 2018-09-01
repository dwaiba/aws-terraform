resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.pegavol.id}"
  instance_id = "${aws_instance.pegaweb.id}"
}

resource "aws_instance" "pegaweb" {
  ami                         = "ami-28e07e50"
  availability_zone           = "us-west-2a"
  instance_type               = "t2.xlarge"
  associate_public_ip_address = "true"
  key_name                    = "${var.key_name}"

  tags {
    Name = "pega"
  }
  user_data = "${file("prep-rhel75.txt")}"
}

resource "aws_ebs_volume" "pegavol" {
  availability_zone = "us-west-2a"
  size              = 50
}

