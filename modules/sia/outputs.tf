output "sia_app_id" {
  value       = azuread_application.sia_app.client_id
  description = "The Application (client) ID of the SIA app"
}
