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
    bypass         = null
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
}



