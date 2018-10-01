variable "key_name" {
  description = "Please input the public key name in eu-central-1 region already present in your account and visible via ec2 console"
}

variable "private_key_path" {
  description = "Path to the private key - for ssh login. Example: ~/.ssh/terraform.pem"
}

variable "region" {}

variable "amis" {
  type = "map"

  default = {
    "eu-central-1a" = "ami-c86c3f23"
  }
}
