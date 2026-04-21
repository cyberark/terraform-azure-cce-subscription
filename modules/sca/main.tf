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

# Look up the SCA resource app's service principal (from commons)
data "azuread_service_principal" "sca_resource_app_sp" {
  client_id = var.shared_resources.resource_app_id
}

# Assign the SCA resource app to the SCA resource custom role at this subscription scope (per sca.sh OnboardAzureResource)
resource "azurerm_role_assignment" "sca_resource_at_subscription" {
  scope              = "/subscriptions/${var.subscription_id}"
  role_definition_id = var.shared_resources.resource_custom_role_id
  principal_id       = data.azuread_service_principal.sca_resource_app_sp.object_id
}
