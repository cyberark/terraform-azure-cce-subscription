variable "subscription_id" {
  description = "The Azure Subscription ID (scope for SCA resource role assignment)"
  type        = string
}

variable "shared_resources" {
  description = "SCA shared resources from commons (resource_app_id, resource_custom_role_id, resource_wif_user_id used here). Validated at subscription root when sca.enable is true."
  type = object({
    resource_app_id         = string
    resource_custom_role_id = string
    resource_wif_user_id    = string
  })
}
