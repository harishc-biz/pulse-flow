module "managedidentity" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.5.0"
  location            = var.region
  name                = "pulse-managed-identity"
  resource_group_name = var.resource_group
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_assignment" "managed_identity_role" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = module.managedidentity.principal_id
}

resource "azurerm_role_assignment" "aks_identity_operator" {
  scope                = module.managedidentity.resource_id
  role_definition_name = "Managed Identity Operator"
  principal_id = module.aks_cluster.kubelet_identity.objectId
}