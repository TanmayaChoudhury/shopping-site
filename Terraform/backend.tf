terraform {
  backend "azurerm" {
    resource_group_name  = "3teir-application"  
    storage_account_name = "3tierapplication150602"                      
    container_name       = "3tierapp-container"                       
    key                  = "dev.terraform.tfstate"        
    use_azuread_auth      = true
  }
  }
