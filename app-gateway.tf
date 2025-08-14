# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
  #redirect_configuration_name    = "${azurerm_virtual_network.vnet.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "agw-terraform-appgw-australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ip.id
  }

  backend_address_pool {
    name  = "${local.backend_address_pool_name}-1"
    fqdns = [azurerm_storage_account.storage[0].primary_web_host]
  }

  backend_address_pool {
    name  = "${local.backend_address_pool_name}-2"
    fqdns = [azurerm_storage_account.storage[1].primary_web_host]
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "${local.listener_name}-1"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = "web1.flcdrg.com"
  }

  http_listener {
    name                           = "${local.listener_name}-2"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = "web2.flcdrg.com"
  }

  request_routing_rule {
    name                       = "${local.request_routing_rule_name}-1"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "${local.listener_name}-1"
    backend_address_pool_name  = "${local.backend_address_pool_name}-1"
    backend_http_settings_name = local.http_setting_name
  }

  request_routing_rule {
    name                       = "${local.request_routing_rule_name}-2"
    priority                   = 10
    rule_type                  = "Basic"
    http_listener_name         = "${local.listener_name}-2"
    backend_address_pool_name  = "${local.backend_address_pool_name}-2"
    backend_http_settings_name = local.http_setting_name
  }
}
