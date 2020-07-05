Table of Contents (EKS and/or AWS RHEL77/centos77 with disks farm with Terraform in any region)
=================

1. [EKS TL;DR](#eks-tldr)

   [Topology](#topology)
2. [EKS and/or AWS bastion user-data with Terraform - RHEL 7.7 and CentOS 7.7 in all regions with disk and with tools](#eks-andor-aws-bastion-user-data-with-terraform---rhel-77-and-centos-77-in-all-regions-with-disk-and-with-tools)
2. [login](#login)
4. **[Automatic provisioning](#high_brightness-automatic-provisioning)**
5. [Create a HA k8s Cluster as IAAS](#create-a-ha-k8s-cluster-as-iaas)
6. [Reporting bugs](#reporting-bugs)
7. [Patches and pull requests](#patches-and-pull-requests)
8. [License](#license)
9. [Code of conduct](#code-of-conduct)

### EKS TL;DR
:beginner: Plan:

`terraform init && terraform plan -var aws_access_key=<<ACCESS KEY>> -var aws_secret_key=<<SECRET KEY>> -var count_vms=0 -var disk_sizegb=30 -var distro=centos7 -var key_name=testdwai -var elbcertpath=~/Downloads/testdwaicert.pem -var private_key_path=~/Downloads/testdwai.pem -var region=us-east-1 -var tag_prefix=k8snodes -out "run.plan"`

:beginner: Apply:

`terraform apply "run.plan"`

:beginner: stackDeploy with aws ingress controller, EFK, prometheus-operator, consul-server/ui:

`export KUBECONFIG=~/aws-terraform/kubeconfig_test-eks && ./deploystack.sh && cd helm && terraform init && terraform plan -out helm.plan && terraform apply helm.plan && kubectl apply -f kubernetes-manifests.yaml && kubectl apply -f all-in-one.yaml`

:beginner: Destroy stack:
`export KUBECONFIG=~/aws-terraform/kubeconfig_test-eks && kubectl delete -f kubernetes-manifests.yaml && kubectl delete -f all-in-one.yaml && terraform destroy --auto-approve`

:beginner: Destroy cluster and other aws resources:

`terraform destroy -var aws_access_key=<<ACCESS KEY>> -var aws_secret_key=<<SECRET KEY>> -var count_vms=0 -var disk_sizegb=30 -var distro=centos7 -var key_name=testdwai -var elbcertpath=~/Downloads/testdwaicert.pem -var private_key_path=~/Downloads/testdwai.pem -var region=us-east-1 -var tag_prefix=k8snodes --auto-approve`

#### Topology

<img src="https://raw.githubusercontent.com/dwaiba/aws-terraform/master/top.png" />


### EKS and/or AWS bastion user-data with Terraform - RHEL 7.7 and CentOS 7.7 in all regions with disk and with tools

1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. [Create new pair via EC2 console for your account and region (us-east-2 default)](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#KeyPairs:sort=keyName) and use the corresponding `Key pair name` value in the console for `key_name` value in `variable.tf`when performing `terraform plan -out "run.plan"`. **Please keep you private pem file handy and note the path.** One can also create a seperate certificate from the private key as follows to be used with the elb secure port **`openssl req -new -x509 -key privkey.pem -out certname.pem -days 3650`**.
3. Collect your  `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY="<< >>"`

> You can generate new ones from your EC2 console via the url for your `<<account_user>>` - `https://console.aws.amazon.com/iam/home?region=us-east-2#/users/<<account_user>>?section=security_credentials`.

4. **Ingress allowance rule is for all and  for `remote-exe` via ssh agentless to run locally in the project to target server - from the ec2 console for the region - us-east-1 or any other region explicitly that you are passing as paramameter. Please make sure to have the private key created or public key imported as a security key for the passed region**
5. `git clone https://github.com/dwaiba/aws-terraform && cd aws-terraform && terraform init && terraform plan -out "run.plan" && terraform apply "run.plan"`.

> Post provisioning **Automatic** `curl http://169.254.169.254/latest/user-data|sudo sh` - via terraform `remote-exec` executes `prep-centos7.txt` `shell-script` file contents of this repo available as user-data, post provisioning. Various type besides `shell-script` including direct `cloud-init` commands may be passed as multipart as part of the user-data via terraform `remote-exec`.
6. To destroy `terraform destroy`

> AWS **RHEl 7.7** AMIs per regios as per `aws ec2 describe-images --owners 309956199498 --query 'Images[*].[CreationDate,Name,ImageId,OwnerId]' --filters "Name=name,Values=RHEL-7.7?*GA*" --region <<region-name>> --output table | sort -r` - Red Hat [Soln. #15356](https://access.redhat.com/solutions/15356)

> AWS **CentOS 7.7** AMIs per regios as per `aws ec2 describe-images --query 'Images[*].[CreationDate,Name,ImageId,OwnerId]' --filters "Name=name,Values=CentOS*7.7*x86_64*" --region <<region-name>> --output table| sort -r`


> AWS **CentOS** AMIs per regions used in map is as per maintained [CentOS Wiki](https://wiki.centos.org/Cloud/AWS#head-78d1e3a4e6ba5c5a3847750d88266916ffe69648)

### Login

As per Output intructions for each  DNS output. 

`chmod 400 <<your private pem file>>.pem && ssh -i <<your private pem file>>.pem ec2-user/centos@<<public address>>`


### :high_brightness: Automatic Provisioning

https://github.com/dwaiba/aws-terraform

:beginner: Pre-req: 

1. private pem file per region available locally and has chmod 400
2. AWS Access key ID, Secret Access key should be available for aws account.

> You can generate new ones from your EC2 console via the url for your `<<account_user>>` - `https://console.aws.amazon.com/iam/home?region=us-east-2#/users/<<account_user>>?section=security_credentials`.

:beginner: Plan:

`terraform init && terraform plan -var aws_access_key=AKIAJBXBOC5JMB5VGGVQ -var aws_secret_key=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 -var count_vms=0 -var disk_sizegb=30 -var distro=centos7 -var key_name=testdwai -var elbcertpath=~/Downloads/testdwaicert.pem -var private_key_path=~/Downloads/testdwai.pem -var region=us-east-1 -var tag_prefix=k8snodes -out "run.plan"`

:beginner: Apply:

`terraform apply "run.plan"`

:beginner: Destroy:

`terraform destroy -var aws_access_key=<<ACCESS KEY>> -var aws_secret_key=<<SECRET KEY>> -var count_vms=0 -var disk_sizegb=30 -var distro=centos7 -var key_name=testdwai -var elbcertpath=~/Downloads/testdwaicert.pem -var private_key_path=~/Downloads/testdwai.pem -var region=us-east-1 -var tag_prefix=k8snodes --auto-approve`


### Create a HA k8s Cluster as IAAS

* One can create a Fully HA k8s Cluster using **[k3sup](https://k3sup.dev/)**

<pre><code><b>curl -sLSf https://get.k3sup.dev | sh && sudo install -m k3sup /usr/local/bin/</b></code></pre>

One can now use k3sup

1. Obtain the Public IPs for the instances running as such `aws ec2 describe-instances` or obtain just the Public IPs as `aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" --output=text`

2. one can use to create a cluster with first ip as master <pre><code>k3sup install --cluster --ip <<<b>Any of the Public IPs</b>>> --user <<<b>ec2-user or centos as per distro</b>>> --ssh-key <<<b>the location of the aws private key like ~/aws-terraform/yourpemkey.pem</b>>></code></pre>

3. one can also join another IP as master or node For master: <pre><code>k3sup join --server --ip <<<b>Any of the other Public IPs</b>>> --user <<<b>ec2-user or centos as per distro</b>>> --ssh-key <<<b>the location of the aws private key like ~/aws-terraform/yourpemkey.pem</b>>> --server-ip <<<b>The Server Public IP</b>>> </code></pre>

<b>or as a simple script</b>:

<pre><code>
export SERVER_IP=$(terraform output -json instance_ips|jq -r '.[]'|head -n 1)

k3sup install --cluster --ip $SERVER_IP --user ec2-user  --ssh-key <b>'Your Private SSH Key Location'</b>--k3s-extra-args '--no-deploy traefik --docker'

terraform output -json instance_ips|jq -r '.[]'|tail -n+2|xargs -I {} k3sup join --server-ip $SERVER_IP --ip {}  --user ec2-user --ssh-key <b>'Your Private SSH Key Location'</b> --k3s-extra-args --docker

export KUBECONFIG=`pwd`/kubeconfig
kubectl get nodes -o wide -w

</code></pre>

* One can create a Fully HA k8s Cluster using **[kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)**

<pre><code><b>kubeadm init</b></code></pre>

One can now use weavenet and join other workers
<pre><code>
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
</code></pre>



### Reporting bugs

Please report bugs  by opening an issue in the [GitHub Issue Tracker](https://github.com/dwaiba/aws-terraform/issues).
Bugs have auto template defined. Please view it [here](https://github.com/dwaiba/aws-terraform/blob/master/.github/ISSUE_TEMPLATE/bug_report.md)

### Patches and pull requests

Patches can be submitted as GitHub pull requests. If using GitHub please make sure your branch applies to the current master as a 'fast forward' merge (i.e. without creating a merge commit). Use the `git rebase` command to update your branch to the current master if necessary.

### License
  * Please see the [LICENSE file](https://github.com/dwaiba/aws-terraform/blob/master/LICENSE) for licensing information.

### Code of Conduct
  * Please see the [Code of Conduct](https://github.com/dwaiba/aws-terraform/blob/master/CODE_OF_CONDUCT.md)
