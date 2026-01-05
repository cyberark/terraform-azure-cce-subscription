output "dummy_app_id" {
  value       = module.cce_cyberark_azure_subscription.dummy_app_id
  description = "The Application (client) ID of the CyberArk Dummy app"
}

output "dummy_two_app_id" {
  value       = module.cce_cyberark_azure_subscription.dummy_two_app_id
  description = "The Application (client) ID of the CyberArk Dummy Two app"
}
