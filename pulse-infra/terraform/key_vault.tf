# 1. Create the Key Vault using AVM
module "keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.9.1"

  name                = "pulseFlowKV"
  resource_group_name = var.resource_group
  location            = var.region
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  legacy_access_policies_enabled = true
  public_network_access_enabled  = true

  network_acls = {
    default_action             = "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = []
  }

  private_endpoints = {
    primary = {
      name                          = "pe-keyvault"
      subnet_resource_id            = module.vnet.subnets["endpoint-subnet"].resource_id
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.kv_dns.id]
    }
  }

  secrets = {
    "sb_secret" = {
      name = "ServiceBusConnectionString"
    },
    "q_secret" = {
      name = "QueueName"
    }
  }

  secrets_value = {
    "sb_secret" = module.servicebus-namespace.resource_authorization_rules["Pulse_SAS"].primary_connection_string
    "q_secret"  = var.queue_name
  }

  legacy_access_policies = {
    "aks_identity_access" = {
      object_id          = module.aks_cluster.kubelet_identity.objectId
      secret_permissions = ["Get", "List"]
    }
  }
}

resource "azurerm_private_dns_zone" "kv_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_link" {
  name                  = "kv-vnet-link"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns.name
  virtual_network_id    = module.vnet.resource_id
}

