data "azurerm_resource_group" "rg" {
  name = "rg-terraform-appgw-australiaeast"
}

data "azurerm_client_config" "current" {
}