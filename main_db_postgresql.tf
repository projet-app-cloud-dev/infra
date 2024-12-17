terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "pokecloud" {
  name     = "pokecloud-resources" # Nom du groupe de ressources
  location = "France Central"      # Localisation de la ressource
}

resource "azurerm_postgresql_flexible_server" "pokecloud" {
  name                = "pokecloudpgserver" # Nom du serveur PostgreSQL
  location            = azurerm_resource_group.pokecloud.location
  resource_group_name = azurerm_resource_group.pokecloud.name

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
