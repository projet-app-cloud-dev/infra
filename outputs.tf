output "azurerm_container_app_url" {
  value = azurerm_container_app.backend-proxy.latest_revision_fqdn
}

output "azurerm_webapp_key" {
  value     = azurerm_static_web_app.pokecloud-app.api_key
  sensitive = true
}
