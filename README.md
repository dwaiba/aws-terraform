# AWS user-data with Terraform

1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. [Upload your public ssh key via EC2 console for your account and region (eu-central-1 default)](https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#KeyPairs:sort=keyName) and use the corresponding `Key pair name` value in the console for `key_name` value in `variable.tf`when performing `terraform plan -out "run.plan"`.
3. please export the following - 
`export AWS_ACCESS_KEY_ID="<<your access key>>" && export AWS_SECRET_ACCESS_KEY="<<your secret access key>>" && export AWS_DEFAULT_REGION="eu-central-1"`. 

> You can generate new ones from your EC2 console via the url for your `<<account_user>>` - `https://console.aws.amazon.com/iam/home?region=eu-central-1#/users/<<account_user>>?section=security_credentials`

> You can convert your private key to pem using 
`ssh-keygen -f ~/.ssh/id_rsa -m 'PEM' -e > public.pem && chmod 600 public.pem`

> You can convert your public key to pem using 
`ssh-keygen -f ~/.ssh/id_rsa -m 'PEM' -e > private.pem && chmod 600 private.pem`

4. Please add ingress allowance rule for port 22 over TCP in the default region VPC for `remote-exe` via ssh agent run in the project to target server - from the ec2 console for the region - eu-central-1
5. `git clone https://github.com/dwaiba/aws-terraform && cd aws-terraform && terraform init && terraform plan -var region=eu-central-1a -out "run.plan" && terraform apply "run.plan" -var region=eu-central-1a`.
> Post provisioning **Automatic** `curl http://169.254.169.254/latest/user-data|sudo sh` - via terraform `remote-exec` executes `prep-rhel75.txt` `shell-script` file contents of this repo available as user-data, post provisioning. Various type besides `shell-script` including direct `cloud-init` commands may be passed as multipart as part of the user-data via terraform `remote-exec`.
6. To destroy `terraform destroy`

### Terraform Graph
Please generate dot format (Graphviz) terraform configuration graphs for visual representation of the repo.

`terraform graph | dot -Tsvg > graph.svg`

Also, one can use [Blast Radius](https://github.com/28mm/blast-radius) on live initialized terraform project to view graph.
Please shoot in dockerized format:

`docker ps -a|grep blast-radius|awk '{print $1}'|xargs docker kill && rm -rf aws-terraform && git clone https://github.com/dwaiba/aws-terraform && cd aws-terraform && terraform init && docker run --cap-add=SYS_ADMIN -dit --rm -p 5002:5000 -v $(pwd):/workdir:ro 28mm/blast-radius && cd ../`

 A live example is [here](http://buildservers.westeurope.cloudapp.azure.com:5002/) for this project. 
