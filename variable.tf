variable "key_name" {
  description = "Please input the public key name for e.g. in eu-central-1 region already present in your account and visible via ec2 console - e.g: https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#KeyPairs:sort=keyName "
}

variable "private_key_path" {
  description = "Path to the private key - for ssh login. Example: ~/.ssh/terraform.pem for post provision remote-exec"
}

variable "region" {}

variable "rhelcreate" {
  description = "Create RHEL 7.5 if set to True"
}

variable "centoscreate" {
  description = "Create CentOS 7.5 if set to True"
}

variable "rhelamis" {
  type = "map"

  default = {
    "eu-central-1" = "ami-c86c3f23"
  }
}

variable "centosamis" {
  type = "map"

  default = {
    "eu-central-1" = "ami-337be65c"
  }
}
