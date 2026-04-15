output "sia_app_id" {
  value       = var.sia.enable ? module.sia[0].sia_app_id : null
  description = "The Application (client) ID of the CyberArk SIA app"
}
