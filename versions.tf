terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "> 3.31.0"
    }
    random = {
      source = "hashicorp/random"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0"
    }
  }

  required_version = ">= 1.1.0"
}
