locals {
  location            = "North Europe"
  resource_group_name = "dev-resourcegroup"
  vnet_details = {
    name          = "dev-vnet"
    address_space = "10.0.0.0/16"
  }
}
  