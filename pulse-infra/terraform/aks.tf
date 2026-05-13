module "aks_cluster" {
  source    = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version   = "0.5.4"
  name      = "pulse_aks"
  location  = var.region
  parent_id = data.azurerm_resource_group.rg.id
  sku = {
    name = "Base"
    tier = "Free"
  }

  default_agent_pool = {
    name                = "system"
    vm_size             = "Standard_B2s_v2"
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
  }

  addon_profile_key_vault_secrets_provider = {
    enabled = true
  }
  namespace = {
    "pulse-dev" = {
      name = "pulse-dev"
      default_resource_quota = {
        cpu_limit      = "2000m"
        cpu_request    = "1000m"
        memory_limit   = "4Gi"
        memory_request = "2Gi"
      }
      default_network_policy = {
        egress  = "AllowAll"
        ingress = "AllowAll"
      }
      adoption_policy = "Always"
      delete_policy   = "Delete"
    }
  }
  addon_profile_oms_agent = {
    enabled = true
    config = {
      log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.logs.id
    }
  }

  tags = {
    app = "Pulse-app"
  }
}


resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks_cluster.identity_principal_id
}
