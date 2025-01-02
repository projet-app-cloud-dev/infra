resource "azurerm_static_web_app" "pokecloud-app" {
  name                = "pokecloud-app"
  resource_group_name = azurerm_resource_group.pokecloud.name
  location            = "westeurope"
}
