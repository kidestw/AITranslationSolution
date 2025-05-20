output "resource_group_name" {
  description = "Name of the resource group."
  value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "Name of the storage account."
  value = azurerm_storage_account.storage.name
}

output "storage_connection_string" {
  description = "Connection string for the storage account."
  value     = azurerm_storage_account.storage.primary_connection_string
  sensitive = true
}

output "input_container_name" {
  description = "Name of the input documents container."
  value = azurerm_storage_container.input_documents.name
}

output "translated_container_name" {
  description = "Name of the translated documents container."
  value = azurerm_storage_container.translated_documents.name
}

output "log_container_name" {
  description = "Name of the log files container."
  value = azurerm_storage_container.log_files.name
}

# Output details for the function app
output "function_app_name" {
  description = "Name of the Function App."
  value = azurerm_linux_function_app.function_app.name
}

output "function_app_default_hostname" {
  description = "Default hostname of the Function App."
  value = azurerm_linux_function_app.function_app.default_hostname
}

output "function_app_principal_id" {
  description = "Principal ID of the Function App's System-Assigned Managed Identity (for RBAC)."
  value       = azurerm_linux_function_app.function_app.identity[0].principal_id
}

# Output details for the web app
output "web_app_name" {
  description = "Name of the Web App."
  value = azurerm_linux_web_app.webapp.name
}

output "web_app_default_hostname" {
  description = "Default hostname of the Web App (where the UI is accessible)."
  value = azurerm_linux_web_app.webapp.default_hostname
}

output "web_app_principal_id" {
  description = "Principal ID of the Web App's System-Assigned Managed Identity (for RBAC)."
  value       = azurerm_linux_web_app.webapp.identity[0].principal_id
}

output "terraform_run_command" {
  description = "Command to run Terraform apply with necessary variables."
  value       = "terraform apply -var='existing_translator_endpoint=YOUR_ENDPOINT' -var='existing_translator_key=YOUR_KEY' -var='existing_translator_region=YOUR_REGION'"
}
