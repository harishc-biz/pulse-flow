locals {
  servicebus_name = lower(format("%spulseSB", var.env))
}

module "servicebus-namespace" {
  source              = "Azure/avm-res-servicebus-namespace/azurerm"
  version             = "0.4.0"
  location            = var.region
  name                = local.servicebus_name
  resource_group_name = var.resource_group
  sku                 = "Basic"

  queues = {
    "work-queue" = {}
  }

  authorization_rules = {
    Pulse_SAS = {
      send   = true
      listen = true
      manage = true
    }
  }
}

