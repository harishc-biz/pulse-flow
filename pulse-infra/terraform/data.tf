data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

data "azurerm_client_config" "current" {}
