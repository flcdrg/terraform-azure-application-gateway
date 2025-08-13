resource "azurerm_public_ip" "ip" {
  name                = "pip-terraform-appgw-australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
}