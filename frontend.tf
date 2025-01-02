resource "azurerm_static_web_app" "pokecloud-app" {
  name                = "pokecloud-app-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.pokecloud.name
  location            = "westeurope"
}
