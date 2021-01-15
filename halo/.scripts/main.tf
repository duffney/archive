provider "azurerm" {
  features{}
  version = "2.9.0"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
  tags      = {
      environment = var.environment
      configVersion = var.configVersion
      owner = var.owner
      client = var.client
    }
}