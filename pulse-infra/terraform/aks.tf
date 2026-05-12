module "aks_cluster" {
  source    = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version   = "0.5.4"
  name      = "pulse_aks"
  location  = var.region
  parent_id = data.azurerm_resource_group.rg.id


  default_agent_pool = {
    name                = "system"
    vm_size             = "Standard_B2s_v2"
    vnet_subnet_id      = module.vnet.subnets["aks-subnet"].resource_id
    count_of            = 1
    enable_auto_scaling = false
    os_disk_type        = "Managed"
  }

  network_profile = {
    
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  api_server_access_profile = {
    vnet_integration_enabled = true
    subnet_id                = module.vnet.subnets["aks-subnet"].resource_id
  }

  addon_profile_key_vault_secrets_provider = {
    enabled = true
  }
  
  managed_identities = {
    system_assigned = true
  }
}


resource "azurerm_role_assignment" "aks_keyvault" {
  principal_id         = module.aks_cluster.kubelet_identity.objectId
  scope                = module.keyvault.resource_id
  role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = module.vnet.subnets["aks-subnet"].resource_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks_cluster.resource.identity[0].principal_id
}