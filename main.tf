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

resource "azurerm_log_analytics_workspace" "pokecloud-workspace" {
  name                = "pokecloud-workspace"
  location            = azurerm_resource_group.pokecloud.location
  resource_group_name = azurerm_resource_group.pokecloud.name
}

resource "azurerm_application_insights" "pokecloud-insights" {
  name                = "pokecloud-insights"
  location            = azurerm_resource_group.pokecloud.location
  resource_group_name = azurerm_resource_group.pokecloud.name
  workspace_id        = azurerm_log_analytics_workspace.pokecloud-workspace.id
  application_type    = "other"
}
