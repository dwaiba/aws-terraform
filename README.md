# AWS user-data with Terraform

1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. [Upload your public ssh key via EC2 console for your account and region (us-west2-default)](https://us-west-.console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:sort=keyName) and use the corresponding `Key pair name` value in the console for `key_name` value in `variable.tf`when performing `terraform plan -out "run.plan"`.
3. please export the following - 
`export AWS_ACCESS_KEY_ID="<<your access key>>" && export AWS_SECRET_ACCESS_KEY="<<your secret access key>>" && export AWS_DEFAULT_REGION="us-west-2"`. 

> You can generate new ones from your EC2 console via the url for your `<<account_user>>` - `https://console.aws.amazon.com/iam/home?region=us-west-2#/users/<<account_user>>?section=security_credentials`

4. `git clone https://github.com/dwaiba/aws-terraform && cd aws-terraform && terraform init && terraform plan -out "run.plan" && terraform apply "run.plan"`.
> Post provisioning **Automatic** `curl http://169.254.169.254/latest/user-data|sudo sh` - via terraform `remote-exec` executes `prep-rhel75.txt` `shell-script` file contents of this repo available as user-data, post provisioning. Various type besides `shell-script` including direct `cloud-init` commands may be passed as multipart as part of the user-data via terraform `remote-exec`.
5. To destroy `terraform destroy`

