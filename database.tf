resource "azurerm_postgresql_flexible_server" "pokecloud" {
  name                          = "pokecloudpgserver" # Nom du serveur PostgreSQL
  location                      = azurerm_resource_group.pokecloud.location
  resource_group_name           = azurerm_resource_group.pokecloud.name
  public_network_access_enabled = true # TODO: make it work

  administrator_login          = "adminuser"       # Identifiant admin
  administrator_password       = "P@ssw0rd1234!"   # Mot de passe (personnalisable avec précaution)
  sku_name                     = "B_Standard_B1ms" # Taille du serveur
  version                      = "16"              # Version PostgreSQL
  storage_mb                   = 32768             # Taille de stockage (modifiable selon les besoins)
  backup_retention_days        = 7                 # Jours de rétention des sauvegardes
  geo_redundant_backup_enabled = false
}

resource "azurerm_postgresql_flexible_server_database" "pokecloud" {
  name      = "pokeclouddb" # Nom de la base de données
  server_id = azurerm_postgresql_flexible_server.pokecloud.id
  charset   = "utf8"       # Jeu de caractères
  collation = "en_US.utf8" # Collation
}


# Allow connections from other Azure Services
resource "azurerm_postgresql_flexible_server_firewall_rule" "postgresql_server_fw" {
  name             = "pokecloudpgserver-fw"
  server_id        = azurerm_postgresql_flexible_server.pokecloud.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}