#Public IP for Load Balancer.
resource "azurerm_public_ip" "dev-public-ip" {
  name                = "PublicIPForLB"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku = "Standard"
}

#Load Balancer.
resource "azurerm_lb" "dev-lb" {
  name                = "DevLoadBalancer"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku = "Standard"
  sku_tier = "Regional"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.dev-public-ip.id
  }
}

#Load Balancer backend Address Pool.
resource "azurerm_lb_backend_address_pool" "dev-backend-add-pool" {
  loadbalancer_id = azurerm_lb.dev-lb.id
  name            = "DevBackEndAddressPool"
}

#Manages a Backend Address within a Backend Address Pool.
resource "azurerm_lb_backend_address_pool_address" "example" {
  count                   = var.number_of_machines
  name                    = "dev-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.dev-backend-add-pool.id
  virtual_network_id      = azurerm_virtual_network.dev-network.id
  ip_address              = azurerm_network_interface.appinterface[count.index].private_ip_address
}

#Health Probe
resource "azurerm_lb_probe" "healthprobe" {
  loadbalancer_id = azurerm_lb.dev-lb.id
  name            = "http-running-probe"
  port            = 80
  protocol        = "Tcp"
}

#Load Balancer Rule
resource "azurerm_lb_rule" "ruleA" {
  loadbalancer_id                = azurerm_lb.dev-lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.healthprobe.id
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.dev-backend-add-pool.id
  ]
}