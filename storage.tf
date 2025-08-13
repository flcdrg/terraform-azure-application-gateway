resource "random_string" "storage_suffix" {
  numeric = true
  special = false
  length  = 3
  upper   = false
}

resource "azurerm_storage_account" "storage" {
  name                             = "sttfappgwaue${random_string.storage_suffix.result}"
  resource_group_name              = data.azurerm_resource_group.rg.name
  location                         = data.azurerm_resource_group.rg.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  min_tls_version                  = "TLS1_2"
}

resource "azurerm_storage_account_static_website" "website" {
  storage_account_id = azurerm_storage_account.storage.id
  index_document     = "index.html"
  error_404_document = "404.html"
}
