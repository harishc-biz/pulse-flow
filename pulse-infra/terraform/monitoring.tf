locals {
  la_name = lower(format("%spulseloganalytics", var.env))
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = local.la_name
  location            = var.region
  resource_group_name = var.resource_group
}