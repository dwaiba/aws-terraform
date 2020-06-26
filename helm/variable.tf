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
variable "bookstack" {
  type = map

  default = {
    "namespace"       = "bookstack"
    "release"         = "bookstack"
    "replicaCount"    = 3
    "mariadb.enabled" = true
    "mariadb.db.name" = "bookstack"
    "mariadb.db.user" = "bookstack"
    "mariadb.master.persistence.enabled"      = true
    "mariadb.master.persistence.storageClass" = "gp2"
    "mariadb.master.persistence.accessMode"   = "ReadWriteOnce"
    "mariadb.master.persistence.size"         = "30Gi"
    "service.type" = "ClusterIP"
    "service.port" = "80"
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
