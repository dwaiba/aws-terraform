variable "aws_alb_ingress_controller" {
  type = map

  default = {

    "namespace"             = "kube-system"
    "clusterName"           = "test-eks"
    "release"               = "aws-alb-ingress-controller"
    "autoDiscoverAwsRegion" = true
    "autoDiscoverAwsVpcID"  = true
  }
}
variable "monitoring" {
  type = map

  default = {
    "namespace" = "monitoring"
    "release"   = "prometheus-operator"
  }
}
/**
variable "openfaas" {
  type = map

  default = {
    "namespace"            = "openfaas"
    "release"              = "openfaas"
    "functionNamespace"    = "openfaas-fn"
    "gateway.replicas"     = 3
    "queueWorker.replicas" = 3
    "operator.create"      = true
    "basic_auth"           = true
    "serviceType"          = "LoadBalancer"
  }
}


variable "falco" {
  type = map

  default = {
    "namespace"                      = "falco"
    "release"                        = "falco"
    "integrations.snsOutput.topic"   = "falco-topic"
    "integrations.snsOutput.enabled" = true
  }
}

variable "kubeless" {
  type = map

  default = {
    "namespace"  = "kubeless"
    "release"    = "kubeless"
    "ui.enabled" = true
  }
}
**/
variable "logging" {
  type = map

  default = {
    "namespace"             = "logging"
    "elasticsearch_release" = "elasticsearch"
    "kibana_release"        = "kibana"
    "filebeat_release"      = "filebeat"
  }
}

variable "consul" {
  type = map

  default = {
    "release"                             = "consul"
    "namespace"                           = "consul"
    "global_enablePodSecurityPolicies"    = true
    "syncCatalog_enabled"                 = true
    "connectInject_enabled"               = true
    "client_enabled"                      = true
    "client_grpc"                         = true
    "connectInject_centralConfig_enabled" = true
    "global_enabled"                      = true
    "server_connect"                      = true
  }
}
/**
variable "region" {
  description = "Regions may be ap-northeast-1, ap-northeast-2, ap-south-1, ap-southeast-1, ap-southeast-2, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, sa-east-1, us-east-1,us-east-2, us-west-1, us-west-2"
}
variable "aws_access_key" {
  description = "The AWS_ACCESS_KEY_ID as obtained. You can generate new ones from your EC2 console via the url for your <<account_user>> - https://console.aws.amazon.com/iam/home?region=<<region>>#/users/<<account_user>>?section=security_credentials"
}
variable "aws_secret_key" {
  description = "The AWS_SECRET_ACCESS_KEY as obtained. You can generate new ones from your EC2 console via the url for your <<account_user>> - https://console.aws.amazon.com/iam/home?region=<<region>>#/users/<<account_user>>?section=security_credentials"
}
**/
