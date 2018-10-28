Table of Contents (AWS RHEL75/centos7 with disks farm with Terraform in any region)
=================

1. [AWS user-data with Terraform - RHEL 7.5 and CentOS 7.5 in all regions with disk and with tools](#aws-user-data-with-terraform-rhel-7.5-and-centOS-7.5-in-all-regions-with-disk-and-with-tools)
2. [login](#login)
3. [Terraform graph](#terraform-graph)
4. [Automatic provisioning](#high_brightness-automatic-provisioning)
5. [Reporting bugs](#reporting-bugs)
6. [Patches and pull requests](#patches-and-pull-requests)

### AWS user-data with Terraform - RHEL 7.5 and CentOS 7.5 in all regions with disk and with tools

1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. [Create new pair via EC2 console for your account and region (eu-central-1 default)](https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#KeyPairs:sort=keyName) and use the corresponding `Key pair name` value in the console for `key_name` value in `variable.tf`when performing `terraform plan -out "run.plan"`. **Please keep you private pem file handy and note the path.**
3. please export the following - 
`export AWS_ACCESS_KEY_ID="<<your access key>>" && export AWS_SECRET_ACCESS_KEY="<<your secret access key>>" && export AWS_DEFAULT_REGION="eu-central-1"`. 

> You can generate new ones from your EC2 console via the url for your `<<account_user>>` - `https://console.aws.amazon.com/iam/home?region=eu-central-1#/users/<<account_user>>?section=security_credentials`.

4. **Please add ingress allowance rule for port 22 over TCP in the default region VPC for `remote-exe` via ssh agent run in the project to target server - from the ec2 console for the region - eu-central-1 or any other region explicitly that you are passing as paramameter.**
5. `git clone https://github.com/dwaiba/aws-terraform && cd aws-terraform && terraform init && terraform plan -out "run.plan" && terraform apply "run.plan"`.

> Post provisioning **Automatic** `curl http://169.254.169.254/latest/user-data|sudo sh` - via terraform `remote-exec` executes `prep-centos7.txt` `shell-script` file contents of this repo available as user-data, post provisioning. Various type besides `shell-script` including direct `cloud-init` commands may be passed as multipart as part of the user-data via terraform `remote-exec`.
6. To destroy `terraform destroy`

> AWS **RHEl 7.5** AMIs per regios as per `aws ec2 describe-images --owners 309956199498 --query 'Images[*].[CreationDate,Name,ImageId]' --filters "Name=name,Values=RHEL-7.5?*GA*" --region <<region-name>> --output table | sort -r` - Red Hat [Soln. #15356](https://access.redhat.com/solutions/15356)


> AWS **CentOS** AMIs per regions used in map is as per maintained [CentOS Wiki](https://wiki.centos.org/Cloud/AWS#head-78d1e3a4e6ba5c5a3847750d88266916ffe69648)

### Login

As per Output intructions for each  DNS output. 

`chmod 400 <<your private pem file>>.pem && ssh -i <<your private pem file>>.pem ec2-user/centos@<<public address>>`


### Terraform Graph
Please generate dot format (Graphviz) terraform configuration graphs for visual representation of the repo.

`terraform graph | dot -Tsvg > graph.svg`

Also, one can use [Blast Radius](https://github.com/28mm/blast-radius) on live initialized terraform project to view graph.
Please shoot in dockerized format:

`docker ps -a|grep blast-radius|awk '{print $1}'|xargs docker kill && rm -rf aws-terraform && git clone https://github.com/dwaiba/aws-terraform && cd aws-terraform && terraform init && docker run --cap-add=SYS_ADMIN -dit --rm -p 5002:5000 -v $(pwd):/workdir:ro 28mm/blast-radius && cd ../`

 A live example is [here](http://buildservers.westeurope.cloudapp.azure.com:5002/) for this project. 

### :high_brightness: Automatic Provisioning

https://github.com/dwaiba/aws-terraform

Pre-req: 
1. private pem file per region available locally and has chmod 400
2. AWS Access key ID, Secret Access key should be available for aws account.

:beginner: Plan:
`export AWS_ACCESS_KEY_ID="<<your AWS Access ID>>" && export AWS_SECRET_ACCESS_KEY="<<your AWS_SECRET_ACCESS_KEY>>" && export AWS_DEFAULT_REGION="<your AWS_DEFAULT_REGION>>" && terraform init && terraform plan -var count_vms=3 -var disk_sizegb=50 -var distro=<<rhel75 or centos7>>  -var key_name=testingdwai -var private_key_path=/data/testingdwai.pem -var region=eu-central-1 -var tag_prefix=toolsrhel75 -out "run.plan"`

:beginner: Apply:
`terraform apply "run.plan"`

:beginner: Destroy:
`export AWS_ACCESS_KEY_ID="<<your AWS Access ID>>" && export AWS_SECRET_ACCESS_KEY="<<your AWS_SECRET_ACCESS_KEY>>" && export AWS_DEFAULT_REGION="<your AWS_DEFAULT_REGION>>" && terraform destroy -var count_vms=2 -var disk_sizegb=50 -var distro=rhel75 -var key_name=testingdwai -var private_key_path=/data/testingdwai.pem -var region=eu-central-1 -var tag_prefix=toolsrhel75`

### Reporting bugs

Please report bugs  by opening an issue in the [GitHub Issue Tracker](https://github.com/dwaiba/aws-terraform/issues).
Bugs have auto template defined. Please view it [here](https://github.com/dwaiba/aws-terraform/blob/master/.github/ISSUE_TEMPLATE/bug_report.md)

### Patches and pull requests

Patches can be submitted as GitHub pull requests. If using GitHub please make sure your branch applies to the current master as a 'fast forward' merge (i.e. without creating a merge commit). Use the `git rebase` command to update your branch to the current master if necessary.