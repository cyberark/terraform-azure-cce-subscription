output "service_app_id" {
  value       = var.service.enable ? module.service[0].service_app_id : null
  description = "The Application (client) ID of the Service app"
}

