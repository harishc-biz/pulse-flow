locals {
  keyvault_name = lower(format("%spulseFlowKV", var.env))
}

module "keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.9.1"

  name                = local.keyvault_name
  resource_group_name = var.resource_group
  location            = var.region
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  legacy_access_policies_enabled = true
  public_network_access_enabled  = true

  network_acls = {
    default_action = "Allow"
    bypass         = "AzureServices"
    ip_rules       = []
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
