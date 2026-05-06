
module "avm-res-network-virtualnetwork" {
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  version       = "0.17.0"
  name          = "pulse_vnet"
  location      = var.region
  parent_id     = data.azurerm_resource_group.rg.id
  address_space = ["20.0.0.0/24"]
}