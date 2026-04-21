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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  required_version = ">= 1.8.5"
}

locals {
  microsoft               = "Microsoft"
  microsoft_cache         = "${local.microsoft}.Cache"
  microsoft_compute       = "${local.microsoft}.Compute"
  microsoft_network       = "${local.microsoft}.Network"
  microsoft_resourcegraph = "${local.microsoft}.ResourceGraph"
  microsoft_resources     = "${local.microsoft}.Resources"
  read                    = "read"
}

# Creates an Azure AD application with a dynamic display name.
resource "azuread_application" "sia_app" {
  display_name = "CyberArk-dpa"
}

# Registers a service principal for the application, enabling role assignments.
resource "azuread_service_principal" "sia_sp" {
  client_id = azuread_application.sia_app.client_id
}

# Generate a UUID
resource "random_uuid" "suffix" {}

# Defines a custom Azure role with specific read permissions, assignable at the subscription or management group level.
resource "azurerm_role_definition" "sia_custom_role" {
  name        = "CyberArk-SIA-Role-${var.subscription_id}-${random_uuid.suffix.result}"
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Read VM custom role for SIA"

  permissions {
    actions = [
      "${local.microsoft_cache}/redis/${local.read}",
      "${local.microsoft_compute}/virtualMachines/${local.read}",
      "${local.microsoft_network}/networkInterfaces/${local.read}",
      "${local.microsoft_network}/privateEndpoints/${local.read}",
      "${local.microsoft_network}/publicIPAddresses/${local.read}",
      "${local.microsoft_network}/virtualNetworks/${local.read}",
      "${local.microsoft_network}/virtualNetworks/subnets/${local.read}",
      "${local.microsoft_resourcegraph}/resources/${local.read}",
      "${local.microsoft_resources}/subscriptions/resourceGroups/${local.read}",
      "${local.microsoft_resources}/tags/${local.read}"
    ]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.subscription_id}"
  ]
}
# Assigns the custom role to the service principal at the defined scope.
resource "azurerm_role_assignment" "sia_role_assignment" {
  scope              = azurerm_role_definition.sia_custom_role.scope
  role_definition_id = azurerm_role_definition.sia_custom_role.role_definition_resource_id
  principal_id       = azuread_service_principal.sia_sp.object_id
}

# Create federated identity credential for the application
resource "azuread_application_federated_identity_credential" "sia_credentials" {
  application_id = azuread_application.sia_app.id
  display_name   = "CyberArk-SIA-Azure-Access"
  description    = "Federated credential for SIA"
  issuer         = var.identity_issuer
  subject        = var.identity_user_id
  audiences      = [var.identity_audience]
}


