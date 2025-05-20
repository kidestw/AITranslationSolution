# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  
  subscription_id = "b6b9cebb-1121-4767-afae-548948b67b28"

  features {}
}

# Random suffix for resource name uniqueness
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# --- Storage Account and Containers ---

resource "azurerm_storage_account" "storage" {
  # Storage account names must be 3-24 characters, lowercase letters and numbers only.
  name                     = "${var.base_name_prefix}sa${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Locally-redundant storage
}

resource "azurerm_storage_container" "input_documents" {
  name                  = "input-documents"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private" # Function trigger works with private
}

resource "azurerm_storage_container" "translated_documents" {
  name                  = "translated-documents"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = var.translated_container_access_type
}

resource "azurerm_storage_container" "log_files" {
  name                  = "log-files"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# --- Function App ---

resource "azurerm_service_plan" "function_plan" {
  name                = "${var.base_name_prefix}-func-plan-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.function_plan_sku # Consumption plan
}

resource "azurerm_linux_function_app" "function_app" {
  name                       = "${var.base_name_prefix}-func-${random_string.suffix.result}"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key # Required for deployment/trigger
  service_plan_id            = azurerm_service_plan.function_plan.id

  site_config {
    application_stack {
      python_version = var.python_version
    }
    always_on = false # Not needed for consumption plan
  }

  # Application settings passed as environment variables to the function code
  app_settings = {
    "AzureWebJobsStorage"                  = azurerm_storage_account.storage.primary_connection_string # Used by function host
    "FUNCTIONS_WORKER_RUNTIME"             = "python"
    "TRANSLATOR_ENDPOINT"                  = var.existing_translator_endpoint # Use existing translator
    "TRANSLATOR_API_KEY"                   = var.existing_translator_key      # Use existing translator key
    "TRANSLATOR_REGION"                    = var.existing_translator_region   # Use existing translator region
    "STORAGE_CONNECTION_STRING"            = azurerm_storage_account.storage.primary_connection_string # Used by function code for blobs
    "INPUT_CONTAINER_NAME"                 = azurerm_storage_container.input_documents.name
    "TRANSLATED_CONTAINER_NAME"            = azurerm_storage_container.translated_documents.name
    "LOG_CONTAINER_NAME"                   = azurerm_storage_container.log_files.name
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = azurerm_storage_account.storage.primary_connection_string # For deployment
    "WEBSITE_CONTENTSHARE"                 = "${var.base_name_prefix}funccontent${random_string.suffix.result}" # Unique share name
    "PYTHON_ENABLE_WORKER_EXTENSIONS"      = "1" # Recommended for Python v2 model with extensions
  }

  identity {
    type = "SystemAssigned"
  }

  # --- Note on Managed Identity ---
  # For enhanced security, consider granting the Function App's Managed Identity (principal ID: azurerm_linux_function_app.function_app.identity[0].principal_id)
  # the following RBAC roles and modifying the function code (__init__.py) to use DefaultAzureCredential:
  # 1. "Storage Blob Data Contributor" on the Storage Account (azurerm_storage_account.storage.id)
  # 2. "Cognitive Services User" on your *existing* Translator resource (you'll need its resource ID).
  # This removes the need for STORAGE_CONNECTION_STRING and TRANSLATOR_API_KEY in app_settings.
}

# --- Web App ---

resource "azurerm_service_plan" "webapp_plan" {
  name                = "${var.base_name_prefix}-webapp-plan-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.webapp_plan_sku
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "${var.base_name_prefix}-webapp-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.webapp_plan.id

  site_config {
    application_stack {
      python_version = var.python_version
    }
    # Command to start the Flask app using Gunicorn
    //startup_command = "gunicorn --bind=0.0.0.0 --timeout 600 app:app"
    //detailed_error_logging_enabled = true
    # Ensure Pip installs packages from requirements.txt during deployment
  
  }

  # Application settings passed as environment variables to the web app code
  app_settings = {
    "STORAGE_CONNECTION_STRING" = azurerm_storage_account.storage.primary_connection_string
    "INPUT_CONTAINER_NAME"      = azurerm_storage_container.input_documents.name
    "TRANSLATED_CONTAINER_NAME" = azurerm_storage_container.translated_documents.name
    # Add other settings like Flask secret key if needed (use Key Vault ideally)
    # "FLASK_SECRET_KEY" = "a-very-secret-key-replace-me" 
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true" # Ensures pip install runs during zip deploy
    "ENABLE_ORYX_BUILD"              = "true" # Use Oryx build system
  }

  identity {
    type = "SystemAssigned"
  }

  # --- Note on Managed Identity & SAS Tokens ---
  # If translated_container_access_type is 'private', the Web App needs a way to grant download access. Options:
  # 1. Generate SAS Tokens: The backend code (app.py) can generate short-lived SAS tokens for download links.
  #    Requires STORAGE_CONNECTION_STRING or Managed Identity with "Storage Blob Data Reader" or "Storage Blob Delegator" role.
  # 2. Use Managed Identity + RBAC: Grant the Web App's Managed Identity (principal ID: azurerm_linux_web_app.webapp.identity[0].principal_id)
  #    the "Storage Blob Data Reader" role on the Storage Account (azurerm_storage_account.storage.id) or specific container.
  #    The web app code then needs modification to use DefaultAzureCredential to access blobs.
}
