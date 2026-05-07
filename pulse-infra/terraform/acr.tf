module "acr" {
  source                  = "Azure/avm-res-containerregistry-registry/azurerm"
  version                 = "0.5.1"
  location                = var.region
  name                    = "flowACR"
  resource_group_name     = var.resource_group
  sku                     = "Basic"
  zone_redundancy_enabled = false
  admin_enabled = true
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.resource_id
  role_definition_name = "AcrPull"
  principal_id = module.aks_cluster.kubelet_identity.objectId
}

resource "azurerm_role_assignment" "aks_acr_push" {
  scope                = module.acr.resource_id
  role_definition_name = "AcrPush"
  principal_id = module.managedidentity.principal_id
}