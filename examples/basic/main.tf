terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    idsec = {
      source  = "cyberark/idsec"
      version = "~> 0.1"
    }
  }

  required_version = ">= 1.8.5"
}

provider "azurerm" {
  subscription_id = "34ea05f7-b5bb-40cd-944e-0f8ba82dc4d9" # Replace with your required subscription id
  features {}
}

provider "azuread" {
}

provider "idsec" {
  # Configure your CyberArk credentials here or via environment variables
  # See: https://registry.terraform.io/providers/cyberark/idsec/latest/docs
}

module "cce_cyberark_azure_subscription" {
  source            = "../../"
  entra_id          = var.entra_id
  entra_tenant_name = var.entra_tenant_name
  subscription_id   = var.subscription_id
  subscription_name = var.subscription_name
  service           = { enable = true }
}

