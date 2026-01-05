terraform {
  required_version = ">= 1.8.5"
}

# Placeholder for identity parameters
# Replace these values with actual identity parameters when available
locals {
  service_identity_issuer   = "https://placeholder-issuer.example.com"
  service_identity_user_id  = "system:serviceaccount:placeholder:placeholder"
  service_identity_audience = "api://placeholder-audience"
}

module "service" {
  source            = "./services_modules/service"
  identity_issuer   = local.service_identity_issuer
  identity_user_id  = local.service_identity_user_id
  identity_audience = local.service_identity_audience
  count             = var.service.enable ? 1 : 0
}
