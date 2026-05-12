terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.70.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.8.0" 
    }
  }
  backend "azurerm" {
    resource_group_name  = "pulse-rg"
    storage_account_name = "pulseterraformstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

