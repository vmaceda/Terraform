variable "admin_username" {
  type = string
  description = "Administrator user name for virtual machine"
  default = "victormaceda"
}

variable "admin_password" {
  type = string
  description = "Password must meet Azure complexity requirements"
  default = "P@$$Worrrrrrd~123"
}

variable "postfix" {
  type = string
  default = "ps"
}


variable "location" {
  type = string
  default = "Australia Southeast"
}


variable "tags" {
    type = map
    default = {
       Environment   = "Prod"
       "Cost Center" = "6100"
       Department    = "Technology"
    }
}

variable "sku" {
    default = {
        "Australia Southeast" = "2019-Datacenter"
        eastus = "2016-Datacenter"
    }
}


provider "azurerm" {
  version = "~>1.31"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "RG-Sydney"
  location = var.location
  tags     = var.tags
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "VNET-10-0-0-0-16"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "SN-10-0-1-0-24"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.1.0/24"
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "PUBIP-VM"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags                = var.tags
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "NSG-Rules"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WWW"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}





# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "NIC-WEBAPP01"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  network_security_group_id = azurerm_network_security_group.nsg.id
  tags                      = var.tags

  ip_configuration {
    name                          = "NICConfig-WEBAPP01"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "WEBAPP01"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B1ls"
  tags                  = var.tags

  storage_os_disk {
    name              = "WEBAPP01-OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = lookup(var.sku, var.location)
    version   = "latest"
  }

  os_profile {
    computer_name  = "WEBAPP01"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config{
   
  }

}

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_virtual_machine.vm.resource_group_name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}

output "os_sku" {
  value = lookup(var.sku, var.location)
}

