provider "azurerm" {
  features{}
  version = "2.9.0"
  #subscription_id = ""
}

resource "azurerm_resource_group" "halo" {
  name     = "haloproto"
  location = "East US"
}

resource "azurerm_app_configuration" "halo" {
  name                = "haloproto"
  resource_group_name = azurerm_resource_group.halo.name
  location            = azurerm_resource_group.halo.location
  depends_on = [azurerm_resource_group.halo]
}

data "azurerm_app_configuration" "halo" {
  name                = "haloproto"
  resource_group_name = azurerm_resource_group.halo.name
}