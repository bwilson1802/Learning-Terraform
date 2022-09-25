

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

##########################
# East V-Net            #
##########################

resource "azurerm_resource_group" "East_US_RG" {
  name     = "East_US_RG"
  location = "East US"
}

resource "azurerm_virtual_network" "EastUS-Network" {
  name                = "EastUS-Network"
  resource_group_name = azurerm_resource_group.East_US_RG.name
  location            = azurerm_resource_group.East_US_RG.location
  address_space       = ["10.10.0.0/16"]
  depends_on          = [azurerm_resource_group.East_US_RG]
}

resource "azurerm_subnet" "LOC-A-Subnet" {
  name                 = "LOC-A-subnet"
  resource_group_name  = azurerm_resource_group.East_US_RG.name
  virtual_network_name = azurerm_virtual_network.EastUS-Network.name
  address_prefixes     = ["10.10.0.0/24"]
  depends_on           = [azurerm_virtual_network.EastUS-Network]
}

##########################
# LOC-A-DC1              #
##########################

resource "azurerm_network_interface" "LOC-A-DC1-NIC" {
  name                = "LOC-A-DC1-NIC"
  location            = azurerm_resource_group.East_US_RG.location
  resource_group_name = azurerm_resource_group.East_US_RG.name
  depends_on          = [azurerm_subnet.LOC-A-Subnet]

  ip_configuration {
    name                          = "EastUS-Network"
    subnet_id                     = azurerm_subnet.LOC-A-Subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_windows_virtual_machine" "LOC-A-DC1" {
  name                  = "LOC-A-DC1"
  resource_group_name   = azurerm_resource_group.East_US_RG.name
  location              = azurerm_resource_group.East_US_RG.location
  size                  = "Standard_B2s"
  admin_username        = "adminuser"
  admin_password        = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.LOC-A-DC1-NIC.id]
  depends_on            = [azurerm_network_interface.LOC-A-DC1-NIC]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}