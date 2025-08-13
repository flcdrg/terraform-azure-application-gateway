resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-terraform-appgw-australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  address_space       = ["10.254.0.0/16"]
}