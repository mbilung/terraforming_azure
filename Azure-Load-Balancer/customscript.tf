# The storage account will be used to store the script for Custom Script extension

resource "azurerm_storage_account" "vmstore200916217" {
  name                     = "vmstore200916217"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  depends_on = [
    azurerm_resource_group.dev-rg
  ]
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = "vmstore200916217"
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.vmstore200916217
  ]
}

resource "azurerm_storage_blob" "IISConfig" {
  name                   = "Set-Config.ps1"
  storage_account_name   = "vmstore200916217"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "Set-Config.ps1"
  depends_on = [
    azurerm_storage_container.data,
    azurerm_storage_account.vmstore200916217
  ]
}


resource "azurerm_virtual_machine_extension" "vmextension" {
  count                = var.number_of_machines
  name                 = "appvm-extension${count.index}"
  virtual_machine_id   = azurerm_windows_virtual_machine.appvm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IISConfig
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.vmstore200916217.name}.blob.core.windows.net/data/Set-Config.ps1"],
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file Set-Config.ps1"     
    }
    SETTINGS
}
