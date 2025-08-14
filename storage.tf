resource "random_string" "storage_suffix" {
  count = 2

  numeric = true
  special = false
  length  = 3
  upper   = false
}

resource "azurerm_storage_account" "storage" {
  count = 2

  name                             = "sttfappgwaue${count.index}${random_string.storage_suffix[count.index].result}"
  resource_group_name              = data.azurerm_resource_group.rg.name
  location                         = data.azurerm_resource_group.rg.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  min_tls_version                  = "TLS1_2"
}

resource "azurerm_storage_account_static_website" "website" {
  count = 2

  storage_account_id = azurerm_storage_account.storage[count.index].id
  index_document     = "index.html"
  error_404_document = "404.html"
}

# Allow workflow/pipeline access to write to blob storage
resource "azurerm_role_assignment" "storage" {
  count = 2

  scope                = azurerm_storage_account.storage[count.index].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

output "storage1_name" {
  value = azurerm_storage_account.storage[0].name
}

output "storage2_name" {
  value = azurerm_storage_account.storage[1].name
}
