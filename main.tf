provider "azurerm" {
  version = "~>1.32.0"
}

resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "eastus"
  tags = {
    Environment   = "Prod"
    "Cost Center" = "6100"
    Department    = "Technology"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name = "myTFVNET"
  address_space = ["10.0.0.0/16"]
  location = "westus2"
  resource_group_name = azurerm_resource_group.rg.name
}

