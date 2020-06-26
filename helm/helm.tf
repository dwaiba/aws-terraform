
resource "helm_release" "consul" {
  name             = lookup(var.consul, "release")
  chart            = "${path.module}/consul-helm"
  namespace        = lookup(var.consul, "namespace")
  create_namespace = "true"

  set {
    name  = "server.replicas"
    value = 3
  }

  set {
    name  = "server.bootstrapExpect"
    value = 3
  }

  set {
    name  = "server.connect"
    value = lookup(var.consul, "server_connect")
  }
  set {
    name  = "global.enablePodSecurityPolicies"
    value = lookup(var.consul, "global_enablePodSecurityPolicies")
  }
  set {
    name  = "syncCatalog.enabled"
    value = lookup(var.consul, "syncCatalog_enabled")
  }
  set {
    name  = "connectInject.enabled"
    value = lookup(var.consul, "connectInject_enabled")
  }
  set {
    name  = "client.enabled"
    value = lookup(var.consul, "client_enabled")
  }
  set {
    name  = "client.grpc"
    value = lookup(var.consul, "client_grpc")
  }
  set {
    name  = "connectInject.centralConfig.enabled"
    value = lookup(var.consul, "connectInject_centralConfig_enabled")
  }

  set {
    name  = "global.enabled"
    value = lookup(var.consul, "global_enabled")
  }
  provisioner "local-exec" {

    command = "helm test ${lookup(var.consul, "release")} --namespace ${lookup(var.consul, "namespace")}"
  }
}
resource "helm_release" "monitoring" {
  name             = lookup(var.monitoring, "release")
  repository       = "https://kubernetes-charts.storage.googleapis.com"
  chart            = lookup(var.monitoring, "release")
  namespace        = lookup(var.monitoring, "namespace")
  create_namespace = "true"

  set {
    name  = "alertmanager.persistentVolume.storageClass"
    value = "gp2"
  }

  set {
    name  = "server.persistentVolume.storageClass"
    value = "gp2"
  }
  provisioner "local-exec" {
    command = "helm test ${lookup(var.monitoring, "release")} --namespace ${lookup(var.monitoring, "namespace")}"
  }
}

resource "helm_release" "aws_alb_ingress_controller" {
  name             = lookup(var.aws_alb_ingress_controller, "release")
  repository       = "http://storage.googleapis.com/kubernetes-charts-incubator"
  chart            = lookup(var.aws_alb_ingress_controller, "release")
  namespace        = lookup(var.aws_alb_ingress_controller, "namespace")
  create_namespace = "true"

  set {
    name  = "clusterName"
    value = lookup(var.aws_alb_ingress_controller, "clusterName")
  }

  set {
    name  = "autoDiscoverAwsRegion"
    value = lookup(var.aws_alb_ingress_controller, "autoDiscoverAwsRegion")
  }

  set {
    name  = "autoDiscoverAwsVpcID"
    value = lookup(var.aws_alb_ingress_controller, "autoDiscoverAwsVpcID")
  }

  provisioner "local-exec" {
    command = "helm test ${lookup(var.aws_alb_ingress_controller, "release")} --namespace ${lookup(var.aws_alb_ingress_controller, "namespace")}"
  }
}

resource "helm_release" "elasticsearch" {
  name             = lookup(var.logging, "elasticsearch_release")
  chart            = "${path.module}/efktemp/elasticsearch"
  namespace        = lookup(var.logging, "namespace")
  create_namespace = "true"
  /**
  provisioner "local-exec" {
    command = "helm test ${lookup(var.logging, "elasticsearch_release")} --namespace ${lookup(var.logging, "namespace")}"
  }
**/
}

resource "helm_release" "filebeat" {
  name             = lookup(var.logging, "filebeat_release")
  chart            = "${path.module}/efktemp/filebeat"
  namespace        = lookup(var.logging, "namespace")
  create_namespace = "true"

  provisioner "local-exec" {
    command = "helm test ${lookup(var.logging, "filebeat_release")} --namespace ${lookup(var.logging, "namespace")}"
  }
}


resource "helm_release" "kibana" {
  name             = lookup(var.logging, "kibana_release")
  chart            = "${path.module}/efktemp/kibana"
  namespace        = lookup(var.logging, "namespace")
  create_namespace = "true"

  provisioner "local-exec" {
    command = "helm test ${lookup(var.logging, "kibana_release")} --namespace ${lookup(var.logging, "namespace")}"
  }
}

/**
resource "helm_release" "bookstack" {
  name             = lookup(var.bookstack, "release")
  repository       = "https://kubernetes-charts.storage.googleapis.com"
  chart            = lookup(var.bookstack, "release")
  namespace        = lookup(var.bookstack, "namespace")
  create_namespace = "true"

  set {
    name  = "replicaCount"
    value = lookup(var.bookstack, "replicaCount")
  }

  set {
    name  = "mariadb.enabled"
    value = lookup(var.bookstack, "mariadb.enabled")
  }
  set {
    name  = "mariadb.db.name"
    value = lookup(var.bookstack, "mariadb.db.name")
  }
  set {
    name  = "mariadb.db.user"
    value = lookup(var.bookstack, "mariadb.db.user")
  }

      set {
    name  = "mariadb.master.persistence.enabled"
    value = lookup(var.bookstack, "mariadb.master.persistence.enabled")
  }
      set {
    name  = "mariadb.master.persistence.storageClass"
    value = lookup(var.bookstack, "mariadb.master.persistence.storageClass")
  }
      set {
    name  = "mariadb.master.persistence.accessMode"
    value = lookup(var.bookstack, "mariadb.master.persistence.accessMode")
  }
      set {
    name  = "mariadb.master.persistence.size"
    value = lookup(var.bookstack, "mariadb.master.persistence.size")
  }
  set {
    name  = "service.type"
    value = lookup(var.bookstack, "service.type")
  }
  set {
    name  = "service.port"
    value = lookup(var.bookstack, "service.port")
  }
  provisioner "local-exec" {
    command = "helm test ${lookup(var.monitoring, "release")} --namespace ${lookup(var.monitoring, "namespace")}"
  }

}
  **/