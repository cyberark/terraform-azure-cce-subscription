variable "subscription_id" {
  description = "The Azure subscription ID (scope for CDS resource role assignment)."
  type        = string
}

variable "shared_resources" {
  description = "CDS shared resources from commons (resource_app_id and resource_custom_role_id used here). Validated at subscription root when **cds.enable** is true."
  type = object({
    resource_app_id         = string
    resource_custom_role_id = string
  })
}
