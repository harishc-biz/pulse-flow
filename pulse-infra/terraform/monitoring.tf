resource "azurerm_log_analytics_workspace" "logs" {
  name                = "pulse-log-analytics"
  location            = var.region
  resource_group_name = var.resource_group
}