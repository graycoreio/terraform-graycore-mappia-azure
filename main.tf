module "keyvault" {
  source = "./keyvault"

  rg_name          = data.azurerm_resource_group.mappia_rg.name
  rg_location      = coalesce(var.location, data.azurerm_resource_group.mappia_rg.location)
  tenant_id        = var.sp_tenant_id
  sp_object_id     = var.sp_object_id
  aks_identity_id  = module.mappia_aks.secret_provider_identity.object_id
  kv_sku_name      = var.kv_sku_name
  kv_name          = var.kv_name
  encryption_key   = var.encryption_key
  shared_cache_pwd = var.shared_cache_pwd
  secrets          = var.secrets
}

module "mappia_aks" {
  source = "./aks"

  rg_name            = data.azurerm_resource_group.mappia_rg.name
  location           = coalesce(var.location, data.azurerm_resource_group.mappia_rg.location)
  name               = var.aks_name
  kubernetes_version = var.kubernetes_version
  dns_prefix         = var.dns_prefix
  default_node_pool  = var.default_node_pool
  extra_node_pools   = var.extra_node_pools
}

resource "helm_release" "mappia_kv_to_aks" {
  name             = "mappia-kv-to-aks"
  repository       = "oci://mappia.azurecr.io/helm"
  chart            = "akvaks"
  version          = "0.0.1"
  namespace        = "default"
  create_namespace = true
  wait             = true
  values = [
    "${file("${path.module}/akv-to-aks.yaml")}"
  ]

  set {
    name  = "keyvaultName"
    value = module.keyvault.mappia_kv_name
  }
  set {
    name  = "tenantId"
    value = var.sp_tenant_id
  }
  set {
    name  = "secretProvider.userAssignedIdentityID"
    value = module.mappia_aks.secret_provider_identity.client_id
  }
}

resource "helm_release" "ingress" {
  name             = "mappia-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx/"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    type  = "string"
    name  = "controller.service.loadBalancerIP"
    value = module.mappia_aks.public_ip_address
  }
  set {
    value = data.azurerm_resource_group.mappia_rg.name
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    type  = "string"
  }
}

module "mappia" {
  source  = "app.terraform.io/graycore/mappia/graycore"
  version = "0.0.1"
  depends_on = [
    helm_release.ingress
  ]

  host = module.mappia_aks.fqdn
  set_values = {
    "installer.enabled" = true
  }
  values = [
    "${file("${path.module}/mappia.yaml")}"
  ]
}
