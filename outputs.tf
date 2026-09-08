output "sia_app_id" {
  value       = var.sia.enable ? module.sia[0].sia_app_id : null
  description = "The Application (client) ID of the CyberArk SIA app"
}

output "subscription_onboarding_id" {
  value       = length(idsec_cce_azure_subscription.create_subscription) > 0 ? idsec_cce_azure_subscription.create_subscription[0].id : null
  description = "The ID of the subscription onboarding resource. Returns null when no service is enabled"
}
