output "server_name" {
  value = azurerm_postgresql_flexible_server.pokecloud.name
}

output "database_name" {
  value = azurerm_postgresql_flexible_server_database.pokecloud.name
}
