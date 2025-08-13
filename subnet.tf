resource "azurerm_subnet" "subnet" {
  name                 = "subnet-terraform-appgw-australiaeast"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.254.0.0/24"]
}