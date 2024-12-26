output "azurerm_container_app_url" {
  value = azurerm_container_app.backend-proxy.latest_revision_fqdn
}
