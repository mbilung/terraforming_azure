resource "azurerm_resource_group" "dev-rg" {
  name     = local.resource_group_name
  location = local.location
}