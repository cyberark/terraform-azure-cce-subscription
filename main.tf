terraform {
  required_providers {
    idsec = {
      source  = "cyberark/idsec"
      version = "0.10.0"
    }
  }

  required_version = ">= 1.8.5"
}

data "idsec_cce_azure_identity_params" "get_wif_data" {}

locals {
  sia_wif_data               = try(data.idsec_cce_azure_identity_params.get_wif_data.identity_params["dpa"], null)
  at_least_1_service_enabled = var.sia.enable == true || var.sca.enable == true
}

module "sia" {
  source            = "./modules/sia"
  subscription_id   = var.subscription_id
  identity_issuer   = local.sia_wif_data["identity_app_issuer"]
  identity_user_id  = local.sia_wif_data["identity_user_id"]
  identity_audience = local.sia_wif_data["identity_app_audience"]
  count             = var.sia.enable ? 1 : 0
}

module "sca" {
  source          = "./modules/sca"
  count           = var.sca.enable && var.sca.shared_resources != null ? 1 : 0
  subscription_id = var.subscription_id
  shared_resources = {
    resource_app_id         = var.sca.shared_resources.resource_app_id
    resource_custom_role_id = var.sca.shared_resources.resource_custom_role_id
    resource_wif_user_id    = var.sca.shared_resources.resource_wif_user_id
  }
}

# Create a simple Azure subscription onboarding
resource "idsec_cce_azure_subscription" "create_subscription" {
  entra_id          = var.entra_id
  entra_tenant_name = var.entra_tenant_name
  subscription_id   = var.subscription_id
  subscription_name = var.subscription_name
  count             = local.at_least_1_service_enabled ? 1 : 0

  depends_on = [module.sca, module.sia, ]

  services = concat(
    # Add sia service if enabled
    var.sia.enable ? [
      {
        service_name = "dpa"
        version      = "0.0.1"
        resources = {
          application_ids = [module.sia[0].sia_app_id]
        }
      }
    ] : [],

    var.sca.enable && var.sca.shared_resources != null ? [
      {
        service_name = "sca"
        version      = "0.0.3"
        resources = {
          applications = [
            {
              application_id            = var.sca.shared_resources.resource_app_id
              identity_trusted_username = var.sca.shared_resources.resource_wif_user_id
            }
          ]
        }
      }
    ] : []
  )
}
