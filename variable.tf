variable "key_name" {
  description = "Hopefully as per README.md pre-req: The three values are set from shell- AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION. Please input the public key name visible via ec2 console (for which you have the private pem file locally) - e.g for eu-central-1: https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#KeyPairs:sort=keyName "
}

variable "private_key_path" {
  description = "Local Path to the private key pem file - for ssh login. Example: ~/.ssh/terraform.pem for post provision remote-exec. Port 22 needs to be opened before provisioning for ingress"
}

variable "region" {
  description = "Regions may be ap-northeast-1, ap-northeast-2, ap-south-1, ap-southeast-1, ap-southeast-2, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, sa-east-1, us-east-1,us-east-2, us-west-1, us-west-2"
}
variable "distro" {
  description = "Please input: rhel75 or centos7"
}
variable "disk_sizegb"{
  description = "Please input the disk size in GB. This would be automatically available as fs ext4 mounted on /data with docker CE volumes linked to /data/docker. "
}
variable "rheluser"{
  default = "ec2-user"
}

variable "centosuser"{
  default ="centos"
}

variable "centosamis" {
  type = "map"

  default = {
    "ap-northeast-1" = "ami-25bd2743"
    "ap-northeast-2" = "ami-7248e81c"
    "ap-south-1"     = "ami-5d99ce32"
    "ap-southeast-1" = "ami-d2fa88ae"
    "ap-southeast-2" = "ami-b6bb47d4"
    "ca-central-1"   = "ami-dcad28b8"
    "eu-central-1"   = "ami-337be65c"
    "eu-west-1"      = "ami-6e28b517"
    "eu-west-2"      = "ami-ee6a718a"
    "eu-west-3"      = "ami-bfff49c2"
    "sa-east-1"      = "ami-f9adef95"
    "us-east-1"      = "ami-4bf3d731"
    "us-east-2"      = "ami-e1496384"
    "us-west-1"      = "ami-65e0e305"
    "us-west-2"      = "ami-a042f4d8"
  }
}
variable "rhelamis" {
  type = "map"

  default = {
	"eu-central-1" = "ami-c86c3f23"
	"us-east-1" = "ami-6871a115"
	"ap-northeast-1" = "ami-6b0d5f0d"
	"ap-northeast-2" = "ami-3eee4150"
	"ap-south-1" = "ami-5b673c34"
	"ap-southeast-1" = "ami-76144b0a"
	"ap-southeast-2" = "ami-67589505"
	"ca-central-1" = "ami-49f0762d"
	"eu-west-1" = "ami-7c491f05"
	"eu-west-2" = "ami-7c1bfd1b"
	"eu-west-3" = "ami-5026902d"
	"sa-east-1" = "ami-b0b7e3dc"
	"us-east-2" = "ami-03291866"
	"us-west-1" = "ami-18726478"
	"us-west-2" =  "ami-28e07e50"
  }
}
