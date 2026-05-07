module "aks_cluster" {
  source    = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version   = "0.5.4"
  name      = "pulse_aks"
  location  = var.region
  parent_id = data.azurerm_resource_group.rg.id

  default_agent_pool = {
    name         = "system"
    vm_size      = "Standard_B2s_v2"
    count_of     = 1
    os_disk_type = "Managed"
  }

  addon_profile_key_vault_secrets_provider = {
    enabled = true
  }
}
