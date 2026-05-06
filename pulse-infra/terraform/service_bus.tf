module "servicebus-namespace" {
source  = "Azure/avm-res-servicebus-namespace/azurerm"
version = "0.4.0"
location = var.region
name = "pulseServiceBus"
resource_group_name = var.resource_group
sku = "Basic"
}