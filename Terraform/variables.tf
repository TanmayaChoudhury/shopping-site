variable "rgname" {
  type        = string
  description = "resource group name"
  
}

variable "location" {
  type    = string
  
}

variable "service_principal_name" {
  type        = string
  description = "Name for the Service Principal"
  
}

variable "keyvault_name" {
  type        = string
  description = "Name for the Azure Key Vault"
  
}

variable "SUB_ID" {
  type        = string
  description = "Azure Subscription ID"
  
}

variable "acr_name" {
  type        = string
  description = "Name for the Azure Container Registry"
}

variable "root_password" {
  description = "Password for the root user stored in Key Vault"
  type        = string
  sensitive   = true
}

variable "grafana_password" {
  description = "Password for Grafana stored in Key Vault"
  type        = string
  sensitive   = true
  
}