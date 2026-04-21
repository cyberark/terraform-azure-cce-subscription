variable "subscription_id" {
  description = "The subscription id for deployment"
  type        = string
}

variable "identity_issuer" {
  description = "Identity issuer for federated credentials"
  type        = string
}

variable "identity_user_id" {
  description = "Identity user ID for federated credentials"
  type        = string
}

variable "identity_audience" {
  description = "Identity audience for federated credentials"
  type        = string
}
