# AWS user-data with Terraform

1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. Install awscli as `pip install awscli`
3. Clone this repository
4. Upload your public ssh key  and use the corresponding `Key pair name` value in the console for `key_name` value in `variable.tf`
5. please export the following `export AWS_ACCESS_KEY_ID="<<your access key>>" && export AWS_SECRET_ACCESS_KEY="<<your secret access key>>" && export AWS_DEFAULT_REGION="us-west-2"`
6. `terraform init && terraform plan -out "run.plan" && terraform apply "run.plan"`. 
7. Post provisioning from inside the box hit `curl http://169.254.169.254/latest/user-data|sudo sh` - injects `prep-rhel75.txt` `shell-script` file contents of this repo available as user-data post provisioning. Various type besides `shell-script` including direct `cloud-init` commands may be passed as multipart.
