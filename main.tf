provider "azurerm" {
  version = "~>1.32.0"
}

resource "azurerm_resource_group" "rg" {
  name = "myTFResourceGroup"
  location = "eastus"

  tags = {
    Environment = "Prod"
    "Cost Center" = "6100"
    Department = "Technology"
  }

}


