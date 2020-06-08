variable "aws_access_key" {
  description = "The AWS_ACCESS_KEY_ID as obtained from You can generate new ones from your EC2 console via the url for your <<account_user>> - https://console.aws.amazon.com/iam/home?region=<<region>>#/users/<<account_user>>?section=security_credentials"
}
variable "aws_secret_key" {
  description = "The AWS_SECRET_ACCESS_KEY as obtained from You can generate new ones from your EC2 console via the url for your <<account_user>> - https://console.aws.amazon.com/iam/home?region=<<region>>#/users/<<account_user>>?section=security_credentials"
}


variable "key_name" {
  description = "Hopefully as per README.md pre-req: The three values are set from shell- AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION. Please input the public key name visible via ec2 console (for which you have the private pem file locally) - e.g for eu-central-1: https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#KeyPairs:sort=keyName "
}

variable "private_key_path" {
  description = "Local Path to the private key pem file - for ssh login. Example: ~/.ssh/terraform.pem for post provision remote-exec. Port 22 needs to be opened before provisioning for ingress"
}

variable "elbcertpath" {
  description = "The absolute cert path for the cert generated from private key pem for the secure elb as 'openssl req -new -x509 -key privkey.pem -out certname.pem -days 3650'"
}
variable "tag_prefix" {
  description = "Prefix Tag to VMs for group identification"
}

variable "count_vms" {
  description = "Number of VMs to create, each with same size disk mounted and available at /data as ext4 fs. All VMs would have same tools."
}

variable "region" {
  description = "Regions may be ap-northeast-1, ap-northeast-2, ap-south-1, ap-southeast-1, ap-southeast-2, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, sa-east-1, us-east-1,us-east-2, us-west-1, us-west-2"
}
variable "distro" {
  description = "Please input: rhel77 or centos7"
}
variable "disk_sizegb" {
  description = "Please input the disk size in GB to be attached to each VM. This would be automatically available as fs ext4 mounted on /data with docker CE volumes linked to /data/docker. "
}
variable "rheluser" {
  default = "ec2-user"
}

variable "centosuser" {
  default = "ec2-user"
}

variable "centosamis" {
  type = map

  default = {
    "ap-northeast-1" = "ami-02aa4ebefd694e352"
    "ap-northeast-2" = "ami-0c608d9a5c8069eb0"
    "ap-south-1"     = "ami-0ca94d8c5e5d84b0d"
    "ap-southeast-1" = "ami-076898e82e2b6835a"
    "ap-southeast-2" = "ami-04c87826f51872f21"
    "ca-central-1"   = "ami-068051358509d0288"
    "eu-central-1"   = "ami-0b21825ca12563d6f"
    "eu-west-1"      = "ami-0eee6eb870dc1cefa"
    "eu-west-2"      = "ami-07b060fcfbdd5ca18"
    "eu-west-3"      = "ami-04a00ba5969dc844c"
    "sa-east-1"      = "ami-083c730c2d91b0dd3"
    "us-east-1"      = "ami-03248a0341eadb1f1"
    "us-east-2"      = "ami-0d302576dc8cef261"
    "us-west-1"      = "ami-01dd5a8ef26e6341d"
    "us-west-2"      = "ami-024b56adf74074ca6"
  }
}
variable "rhelamis" {
  type = map

  default = {
    "eu-central-1"   = "ami-062dacb006c5860f9"
    "us-east-1"      = "ami-0916c408cb02e310b"
    "ap-northeast-1" = "ami-0dc41c7805e171046"
    "ap-northeast-2" = "ami-0b5425629eb18a008"
    "ap-south-1"     = "ami-021912f2c8d2c70c9"
    "ap-southeast-1" = "ami-07cafca3788493264"
    "ap-southeast-2" = "ami-0f1ef883e90ca71c0"
    "ca-central-1"   = "ami-05816666b3178f208"
    "eu-west-1"      = "ami-0a0d2dc2f521ddce6"
    "eu-west-2"      = "ami-096fbd31de0375d2a"
    "eu-west-3"      = "ami-025fb013ee01513b5"
    "sa-east-1"      = "ami-048b2348ac2ccfc53"
    "us-east-2"      = "ami-03cfe750d5ea278f5"
    "us-west-1"      = "ami-0388d197bb42be9be"
    "us-west-2"      = "ami-04b7963c90686dd4c"
  }
}
