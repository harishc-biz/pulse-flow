
# module "vnet" {
#   source        = "Azure/avm-res-network-virtualnetwork/azurerm"
#   version       = "0.17.0"
#   name          = "pulse_vnet"
#   location      = var.region
#   parent_id     = data.azurerm_resource_group.rg.id
#   address_space = ["10.0.0.0/16"]

#   subnets = {
#     "aks-subnet" = {
#       name             = "snet-aks"
#       address_prefixes = ["10.0.1.0/24"]
#       delegations = [{
#         name = "aks-delegation"
#         service_delegation = {
#           name    = "Microsoft.ContainerService/managedClusters"
#           actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
#         }
#       }]
#     }
#     "endpoint-subnet" = {
#       name             = "snet-endpoints"
#       address_prefixes = ["10.0.2.0/24"]
#     }
#   }
# }

