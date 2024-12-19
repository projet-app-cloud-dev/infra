output "server_name" {
  value = azurerm_postgresql_flexible_server.pokecloud.name
}

output "database_name" {
  value = azurerm_postgresql_flexible_server_database.pokecloud.name
}


output "resource_group_name" {
  value = azurerm_resource_group.pokecloud.name
}
output "azurerm_container_app_url" {
  value = azurerm_container_app.backend-proxy.latest_revision_fqdn
}
