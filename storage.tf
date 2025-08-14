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

# Allow workflow/pipeline access to write to blob storage
resource "azurerm_role_assignment" "storage" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

output "storage1" {
  value = azurerm_storage_account.storage.name
}
