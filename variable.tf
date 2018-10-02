variable "key_name" {
  description = "Please input the public key name for e.g. in eu-central-1 region already present in your account and visible via ec2 console - e.g: https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#KeyPairs:sort=keyName "
}

variable "private_key_path" {
  description = "Path to the private key - for ssh login. Example: ~/.ssh/terraform.pem for post provision remote-exec"
}

variable "region" {}

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
