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

resource "azurerm_container_app_environment" "backendenv" {
  name                = "backend-env"
  location            = azurerm_resource_group.pokecloud.location
  resource_group_name = azurerm_resource_group.pokecloud.name

  depends_on = [
    azurerm_postgresql_flexible_server.pokecloud
  ]

  // log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_container_app" "backend-proxy" {
  name                         = "backend-proxy"
  container_app_environment_id = azurerm_container_app_environment.backendenv.id
  resource_group_name          = azurerm_resource_group.pokecloud.name
  revision_mode                = "Single"

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  secret {
    name  = "ghcr-password"
    value = var.ghcr_password
  }

  registry {
    server               = "ghcr.io"
    username             = var.ghcr_username
    password_secret_name = "ghcr-password"
  }

  template {
    container {
      name   = "proxy"
      image  = "ghcr.io/projet-app-cloud-dev/proxy:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}

resource "random_bytes" "jwt_secret" {
  length = 256
}

resource "azurerm_container_app" "backend" {
  name                         = each.key
  container_app_environment_id = azurerm_container_app_environment.backendenv.id
  resource_group_name          = azurerm_resource_group.pokecloud.name
  revision_mode                = "Single"

  for_each = toset(["auth", "collection", "cards"])

  secret {
    name  = "ghcr-password"
    value = var.ghcr_password
  }



  registry {
    server               = "ghcr.io"
    username             = var.ghcr_username
    password_secret_name = "ghcr-password"
  }

  ingress {
    external_enabled = false
    transport        = "tcp"
    exposed_port     = 8080
    target_port      = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "collection"
      image  = "ghcr.io/projet-app-cloud-dev/${each.key}:main"
      cpu    = 0.5
      memory = "1Gi"
      env {
        name  = "DB_USERNAME"
        value = azurerm_postgresql_flexible_server.pokecloud.administrator_login
      }
      env {
        name  = "DB_PASSWORD"
        value = azurerm_postgresql_flexible_server.pokecloud.administrator_password
      }
      env {
        name  = "DB_HOST_PORT"
        value = "${azurerm_postgresql_flexible_server.pokecloud.fqdn}:5432"
      }
      env {
        name  = "API_KEY"
        value = var.tgc_api_key
      }
      env {
        name  = "JWT_KEY"
        value = random_bytes.jwt_secret.base64
      }
    }
  }
}
