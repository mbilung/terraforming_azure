resource "azurerm_virtual_network" "dev-network" {
  name                = local.vnet_details.name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [local.vnet_details.address_space]
}

resource "azurerm_subnet" "dev-subnet" {
  name                 = "subnetA"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_details.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on           = [azurerm_virtual_network.dev-network]
}

resource "azurerm_network_security_group" "appnsg" {
  name                = "app-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3389
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Development"
  }

  depends_on = [azurerm_virtual_network.dev-network]
}

resource "azurerm_subnet_network_security_group_association" "appnsglink" {
  subnet_id                 = azurerm_subnet.dev-subnet.id
  network_security_group_id = azurerm_network_security_group.appnsg.id
  depends_on = [
    azurerm_virtual_network.dev-network,
    azurerm_network_security_group.appnsg
  ]
}