resource "azurerm_container_app_environment" "backendenv" {
  name                = "pokecloud-backend-env-${terraform.workspace}"
  location            = azurerm_resource_group.pokecloud.location
  resource_group_name = azurerm_resource_group.pokecloud.name

  depends_on = [
    azurerm_postgresql_flexible_server.pokecloud
  ]

  log_analytics_workspace_id = azurerm_log_analytics_workspace.pokecloud-workspace.id
}

resource "azurerm_container_app" "backend-proxy" {
  name                         = "pokecloud-backend-proxy-${terraform.workspace}"
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
      image  = "ghcr.io/projet-app-cloud-dev/proxy:${terraform.workspace == "prod" ? var.proxy_prod_version : "main"}"
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

  for_each = tomap({
    "auth"       = terraform.workspace == "prod" ? var.auth_prod_version : "main",
    "collection" = terraform.workspace == "prod" ? var.collection_prod_version : "main",
    "cards"      = terraform.workspace == "prod" ? var.cards_prod_version : "main"
  })

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
      name   = "pokecloud-backend-${each.key}-${terraform.workspace}"
      image  = "ghcr.io/projet-app-cloud-dev/${each.key}:${each.value}"
      cpu    = 0.75
      memory = "1.5Gi"
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
        name  = "JWT_KEY"
        value = random_bytes.jwt_secret.base64
      }
      env {
        name  = "APP_INSIGHTS"
        value = azurerm_application_insights.pokecloud-insights.connection_string
      }
    }
  }
}
