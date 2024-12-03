terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "pokecloud" {
  name     = "pokecloud-resources" # Nom du groupe de ressources
  location = "West Europe"         # Localisation de la ressource
}

resource "azurerm_postgresql_flexible_server" "pokecloud" {
  name                = "pokecloudpgserver" # Nom du serveur PostgreSQL
  location            = azurerm_resource_group.pokecloud.location
  resource_group_name = azurerm_resource_group.pokecloud.name

  administrator_login          = "adminuser"   # Identifiant admin
  administrator_password        = "P@ssw0rd1234!" # Mot de passe (personnalisable avec précaution)
  sku_name                     = "Standard_B1ms" # Taille du serveur
  version                      = "17"           # Version PostgreSQL
  storage_mb                   = 2147          # Taille de stockage (modifiable selon les besoins)
  backup_retention_days        = 2              # Jours de rétention des sauvegardes
  geo_redundant_backup_enabled = false
}

resource "azurerm_postgresql_flexible_server_database" "pokecloud" {
  name                = "pokeclouddb" # Nom de la base de données
  resource_group_name = azurerm_resource_group.pokecloud.name
  server_name         = azurerm_postgresql_flexible_server.pokecloud.name
  charset             = "UTF8"        # Jeu de caractères
  collation           = "en_US.UTF8"  # Collation
}
