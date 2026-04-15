variable "entra_id" {
  description = "The Azure entra ID"
  type        = string
}

variable "entra_tenant_name" {
  description = "The Azure entra name"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "subscription_name" {
  description = "The Azure subscription name"
  type        = string
}

variable "sia" {
  description = "Configuration for the sia feature."
  type = object({
    enable = optional(bool, true)
  })
  default = { enable = false }
}

variable "sca" {
  description = "SCA config. When enable is true, shared_resources (from commons output) is required; subscription only consumes it and assigns resource app to this subscription scope."
  type = object({
    enable = optional(bool, false)
    shared_resources = optional(object({
      entra_app_id            = optional(string)
      entra_custom_role_id    = optional(string)
      entra_wif_user_id       = optional(string)
      resource_app_id         = optional(string)
      resource_custom_role_id = optional(string)
      resource_wif_user_id    = optional(string)
    }), null)
  })
  default = { enable = false, shared_resources = null }

  validation {
    condition = (
      !var.sca.enable ||
      (var.sca.shared_resources != null &&
        try(var.sca.shared_resources.resource_app_id, null) != null &&
        try(length(var.sca.shared_resources.resource_app_id), 0) > 0 &&
        try(var.sca.shared_resources.resource_custom_role_id, null) != null &&
        try(length(var.sca.shared_resources.resource_custom_role_id), 0) > 0 &&
        try(var.sca.shared_resources.resource_wif_user_id, null) != null &&
      try(length(var.sca.shared_resources.resource_wif_user_id), 0) > 0)
    )
    error_message = "When SCA is enabled (sca.enable = true), sca.shared_resources must be set with non-empty resource_app_id, resource_custom_role_id, and resource_wif_user_id (from commons output)."
  }
}

