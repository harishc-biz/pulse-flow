module "acr" {
  source                  = "Azure/avm-res-containerregistry-registry/azurerm"
  version                 = "0.5.1"
  location                = var.region
  name                    = "flowACR"
  resource_group_name     = var.resource_group
  sku                     = "Basic"
  zone_redundancy_enabled = false
}