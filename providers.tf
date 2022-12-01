terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.31.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"

  subscription_id = var.subscription_id
  client_id       = var.sp_id
  client_secret   = var.sp_secret
  tenant_id       = var.sp_tenant_id
}

provider "helm" {
  kubernetes {
    host = module.mappia_aks.kube_config_host

    client_certificate     = base64decode(module.mappia_aks.kube_config_client_cert)
    client_key             = base64decode(module.mappia_aks.kube_config_client_key)
    cluster_ca_certificate = base64decode(module.mappia_aks.kube_config_ca_cert)
  }
}
