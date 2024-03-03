resource "azurerm_network_interface" "appinterface" {
  count               = var.number_of_machines
  name                = "appinterface${count.index}"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_subnet.dev-subnet
  ]
}

resource "azurerm_windows_virtual_machine" "appvm" {
  count               = var.number_of_machines
  name                = "machine${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_F2"
  admin_username      = "adminuser${count.index}"
  admin_password      = "P@$$w0rd1234!"
  availability_set_id = azurerm_availability_set.appset.id
  network_interface_ids = [
    azurerm_network_interface.appinterface[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_virtual_network.dev-network,
    azurerm_network_interface.appinterface,
    azurerm_availability_set.appset
  ]
}