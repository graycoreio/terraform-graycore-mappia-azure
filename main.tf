locals {
  location = coalesce(var.location, data.azurerm_resource_group.mappia_rg.location)
}

resource "helm_release" "mappia_kv_to_aks" {
  name             = "mappia-kv-to-aks"
  repository       = "oci://mappia.azurecr.io/helm"
  chart            = "akvaks"
  version          = var.helm_akvaks_chart_version
  namespace        = "default"
  create_namespace = true
  wait             = true
  values = compact([
    "${file("${path.module}/akv-to-aks.yaml")}",
    fileexists(var.helm_akvaks_values) ? "${file(var.helm_akvaks_values)}" : ""
  ])

  depends_on = [
    azurerm_kubernetes_cluster.mappia_aks
  ]

  set {
    name  = "keyvaultName"
    value = azurerm_key_vault.mappia-kv.name
  }
  set {
    name  = "tenantId"
    value = var.sp_tenant_id
  }
  set {
    name  = "secretProvider.userAssignedIdentityID"
    value = azurerm_kubernetes_cluster.mappia_aks.key_vault_secrets_provider[0].secret_identity[0].client_id
  }
}

resource "helm_release" "ingress" {
  name             = var.helm_ingress_name
  repository       = "https://kubernetes.github.io/ingress-nginx/"
  chart            = "ingress-nginx"
  namespace        = var.helm_ingress_namespace
  create_namespace = true

  depends_on = [
    azurerm_kubernetes_cluster.mappia_aks,
    azurerm_role_assignment.aks_identity_ip_role_permission
  ]

  set {
    type  = "string"
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.mappia_ip.ip_address
  }
  set {
    value = data.azurerm_resource_group.mappia_rg.name
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    type  = "string"
  }

  values = fileexists(var.helm_ingress_values) ? ["${file(var.helm_ingress_values)}"] : []
}

module "mappia" {
  source = "../mappia"
  # version = "0.3.2" # x-release-please-version
  depends_on = [
    helm_release.ingress
  ]

  host               = azurerm_public_ip.mappia_ip.fqdn
  name               = var.helm_mappia_name
  set_values         = var.helm_mappia_set_values
  use_default_config = var.helm_mappia_use_default_config
  chart_version      = var.helm_mappia_chart_version

  values = compact([
    "${file("${path.module}/mappia.yaml")}",
    fileexists(var.helm_mappia_values) ? "${file(var.helm_mappia_values)}" : ""
  ])
}
