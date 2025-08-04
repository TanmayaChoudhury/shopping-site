terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.8.0"
    }
  }

  required_version = ">=1.9.0"
}

provider "azurerm" {
    features {
      
    }
  subscription_id = "166ebec3-2c7c-49d3-921e-94a11571914c"
}