variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
  default     = "translationproject-kid-rg"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed. Should match your existing Translator region."
  default     = "West Europe" 
}

variable "base_name_prefix" {
  type        = string
  description = "Base name prefix for resources (e.g., storage account, function app). Keep it short and lowercase."
  default     = "transprojkid" # Adjusted for storage account name rules
}

# --- Existing Translator Variables ---
variable "existing_translator_endpoint" {
  type        = string
  description = "The endpoint URL of your existing Azure Translator resource."
  # Example: "https://your-translator-name.cognitiveservices.azure.com/"
}

variable "existing_translator_key" {
  type        = string
  description = "The API key for your existing Azure Translator resource. Consider using Managed Identity + RBAC for better security."
  sensitive   = true
}

variable "existing_translator_region" {
  type        = string
  description = "The Azure region of your existing Azure Translator resource (e.g., 'eastus'). Required for Document Translation SDK."
}
# --- End Existing Translator Variables ---

variable "translator_sku" {
  type        = string
  description = "SKU for the Translator service (used for info, not creation)."
  default     = "F0" # Or S1 etc. - reflects your existing service tier
}

variable "function_plan_sku" {
  type        = string
  description = "SKU for the Function App consumption plan."
  default     = "Y1" 
}

variable "webapp_plan_sku" {
  type        = string
  description = "SKU for the Web App plan (e.g., B1, S1)."
  default     = "B1" 
}

variable "python_version" {
  type        = string
  description = "Python version for Function App and Web App."
  default     = "3.11"
}

variable "translated_container_access_type" {
  type        = string
  description = "Access type for the translated-documents container ('private' or 'blob'). 'blob' allows direct URL access (simpler but less secure), 'private' requires SAS tokens or Managed Identity access from the web app."
  default     = "blob" 
}

variable "input_container_sas" {}
variable "translated_container_sas" {}
variable "log_container_sas" {}
