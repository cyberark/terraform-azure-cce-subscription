output "sia_app_id" {
  value       = var.sia.enable ? module.sia[0].sia_app_id : null
  description = "The SIA app (client) ID."
}

output "subscription_onboarding_id" {
  value       = length(idsec_cce_azure_subscription.create_subscription) > 0 ? idsec_cce_azure_subscription.create_subscription[0].id : null
  description = "The subscription onboarding resource ID. Returns null when no service is enabled."
}
