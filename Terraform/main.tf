data "azuread_client_config" "current1" {}

resource "azurerm_resource_group" "rg1" {
  name     = var.rgname
  location = var.location
}

module "ServicePrincipal" {
  source                 = "./modules/service-principal"
  service_principal_name = var.service_principal_name

  depends_on = [
    azurerm_resource_group.rg1
  ]
}


resource "azurerm_role_assignment" "rolespn" {

  scope                = "/subscriptions/${var.SUB_ID}"
  role_definition_name = "Contributor"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on = [
    module.ServicePrincipal
  ]

}

resource "azurerm_role_assignment" "rolespn1" {

  scope                = "/subscriptions/${var.SUB_ID}"
  role_definition_name = "User Access Administrator"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on = [
    module.ServicePrincipal
  ]

}

module "keyvault" {
  source                      = "./modules/keyvault"
  keyvault_name               = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.rgname
  service_principal_name      = var.service_principal_name
  service_principal_object_id = module.ServicePrincipal.service_principal_object_id
  service_principal_tenant_id = module.ServicePrincipal.service_principal_tenant_id

  depends_on = [
    module.ServicePrincipal
  ]
}

resource "azurerm_key_vault_secret" "example" {
  name         = module.ServicePrincipal.client_id
  value        = module.ServicePrincipal.client_secret
  key_vault_id = module.keyvault.keyvault_id

  depends_on = [
    module.keyvault,
    azurerm_role_assignment.sp_keyvault_secrets_officer,
    azurerm_role_assignment.terraform_sp_keyvault_access
  ]
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


#create Azure Kubernetes Service
module "aks" {
  source                 = "./modules/aks-cluster/"
  service_principal_name = var.service_principal_name
  client_id              = module.ServicePrincipal.client_id
  client_secret          = module.ServicePrincipal.client_secret
  location               = var.location
  resource_group_name    = var.rgname
  aks_subnet_id          = azurerm_subnet.aks_subnet.id
  #app_gateway_id         = azurerm_application_gateway.appgw.id
  ssh_public_key = tls_private_key.ssh_key.public_key_openssh
  

  depends_on = [
    module.ServicePrincipal
  ]

}


resource "azurerm_role_assignment" "sp_keyvault_secrets_officer" {
  scope                = module.keyvault.keyvault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on = [
    module.keyvault,
    azurerm_role_assignment.terraform_sp_keyvault_access,

  ]
}


resource "azurerm_role_assignment" "terraform_sp_keyvault_access" {
  scope                = module.keyvault.keyvault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_client_config.current1.object_id

  depends_on = [
    module.keyvault
  ]
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  sku                 = "Standard"
}

resource "azurerm_role_assignment" "example" {
  principal_id                     = module.ServicePrincipal.service_principal_object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
  depends_on = [ 
    azurerm_container_registry.acr,
    module.aks
   ]
}


resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_key_vault_secret" "root_user" {
  name         = "root"
  value        = var.root_password
  key_vault_id = module.keyvault.keyvault_id

  depends_on = [
    azurerm_role_assignment.sp_keyvault_secrets_officer,
    azurerm_role_assignment.terraform_sp_keyvault_access
  ]
}

resource "azurerm_key_vault_secret" "grafana_user" {
  name         = "grafana"
  value        = var.grafana_password
  key_vault_id = module.keyvault.keyvault_id

  depends_on = [
    azurerm_role_assignment.sp_keyvault_secrets_officer,
    azurerm_role_assignment.terraform_sp_keyvault_access
  ]
}