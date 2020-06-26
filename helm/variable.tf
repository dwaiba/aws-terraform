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
