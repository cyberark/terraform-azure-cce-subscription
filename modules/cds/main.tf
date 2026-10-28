terraform {
  required_version = ">= 1.8.5"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

data "azuread_service_principal" "cds_resource_app_sp" {
  client_id = var.shared_resources.resource_app_id
}

resource "azurerm_role_assignment" "cds_resource_at_subscription" {
  scope = "/subscriptions/${var.subscription_id}"
  # Subscription-scoped ID, as Azure returns it; the unscoped ID causes a replacement on every plan
  role_definition_id = "/subscriptions/${var.subscription_id}${var.shared_resources.resource_custom_role_id}"
  principal_id       = data.azuread_service_principal.cds_resource_app_sp.object_id
}
