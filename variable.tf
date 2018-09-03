variable "key_name" {
  description = "Please input the public key name in us-west2 region already present in your account and visible via ec2 console"
}

variable "private_key_path" {
  description = "Path to the private key - for ssh login. Example: ~/.ssh/terraform.pem"
}

