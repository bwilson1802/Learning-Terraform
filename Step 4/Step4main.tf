###################################
# Dev Test script,                #
# Passwords hardcoded             #
#                                 #
###################################

################
#  Base Setup  #
################

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

resource "azurerm_subnet" "LOC-B-Subnet" {
  name                 = "LOC-B-subnet"
  resource_group_name  = azurerm_resource_group.East_US_RG.name
  virtual_network_name = azurerm_virtual_network.EastUS-Network.name
  address_prefixes     = ["10.10.1.0/24"]
  depends_on           = [azurerm_virtual_network.EastUS-Network]
}

##########################
# West V-Net            #
##########################

resource "azurerm_resource_group" "West_US_RG" {
  name     = "West_US_RG"
  location = "West US 3"
}

resource "azurerm_virtual_network" "WestUS-Network" {
  name                = "WestUS-Network"
  resource_group_name = azurerm_resource_group.West_US_RG.name
  location            = azurerm_resource_group.West_US_RG.location
  address_space       = ["10.11.0.0/16"]
  depends_on          = [azurerm_resource_group.West_US_RG]
}

resource "azurerm_subnet" "LOC-C-Subnet" {
  name                 = "LOC-C-subnet"
  resource_group_name  = azurerm_resource_group.West_US_RG.name
  virtual_network_name = azurerm_virtual_network.WestUS-Network.name
  address_prefixes     = ["10.11.1.0/24"]
  depends_on           = [azurerm_virtual_network.WestUS-Network]
}

resource "azurerm_subnet" "LOC-D-Subnet" {
  name                 = "LOC-D-subnet"
  resource_group_name  = azurerm_resource_group.West_US_RG.name
  virtual_network_name = azurerm_virtual_network.WestUS-Network.name
  address_prefixes     = ["10.11.2.0/24"]
  depends_on           = [azurerm_virtual_network.WestUS-Network]
}

##########################
# V-Net Peering          #
##########################

variable "location" {
  default = [
    "East US",
    "West US 3",
  ]
}

variable "vnet_address_space" {
  default = [
    "10.10.0.0/16",
    "10.11.0.0/16",
  ]
}

resource "azurerm_virtual_network_peering" "E-to-W-peering" {
  name                      = "E-to-W-peering"
  resource_group_name       = azurerm_resource_group.East_US_RG.name
  virtual_network_name      = azurerm_virtual_network.EastUS-Network.name
  remote_virtual_network_id = azurerm_virtual_network.WestUS-Network.id
}

resource "azurerm_virtual_network_peering" "W-to_E-Peering" {
  name                      = "W-to_E-Peering"
  resource_group_name       = azurerm_resource_group.West_US_RG.name
  virtual_network_name      = azurerm_virtual_network.WestUS-Network.name
  remote_virtual_network_id = azurerm_virtual_network.EastUS-Network.id
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

##########################
# LOC-B-DC1              #
##########################

resource "azurerm_network_interface" "LOC-B-DC1-NIC" {
  name                = "LOC-B-DC1-NIC"
  location            = azurerm_resource_group.East_US_RG.location
  resource_group_name = azurerm_resource_group.East_US_RG.name
  depends_on          = [azurerm_subnet.LOC-B-Subnet]

  ip_configuration {
    name                          = "EastUS-Network"
    subnet_id                     = azurerm_subnet.LOC-B-Subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_windows_virtual_machine" "LOC-B-DC1" {
  name                  = "LOC-B-DC1"
  resource_group_name   = azurerm_resource_group.East_US_RG.name
  location              = azurerm_resource_group.East_US_RG.location
  size                  = "Standard_B2s"
  admin_username        = "adminuser"
  admin_password        = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.LOC-B-DC1-NIC.id]
  depends_on            = [azurerm_network_interface.LOC-B-DC1-NIC]

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

##########################
# LOC-C-DC1              #
##########################

resource "azurerm_network_interface" "LOC-C-DC1-NIC" {
  name                = "LOC-C-DC1-NIC"
  location            = azurerm_resource_group.West_US_RG.location
  resource_group_name = azurerm_resource_group.West_US_RG.name
  depends_on          = [azurerm_subnet.LOC-C-Subnet]

  ip_configuration {
    name                          = "WestUS-Network"
    subnet_id                     = azurerm_subnet.LOC-C-Subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_windows_virtual_machine" "LOC-C-DC1" {
  name                  = "LOC-C-DC1"
  resource_group_name   = azurerm_resource_group.West_US_RG.name
  location              = azurerm_resource_group.West_US_RG.location
  size                  = "Standard_B2s"
  admin_username        = "adminuser"
  admin_password        = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.LOC-C-DC1-NIC.id]
  depends_on            = [azurerm_network_interface.LOC-C-DC1-NIC]

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

##########################
# LOC-D-DC1              #
##########################

resource "azurerm_network_interface" "LOC-D-DC1-NIC" {
  name                = "LOC-D-DC1-NIC"
  location            = azurerm_resource_group.West_US_RG.location
  resource_group_name = azurerm_resource_group.West_US_RG.name
  depends_on          = [azurerm_subnet.LOC-D-Subnet]

  ip_configuration {
    name                          = "WestUS-Network"
    subnet_id                     = azurerm_subnet.LOC-D-Subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_windows_virtual_machine" "LOC-D-DC1" {
  name                  = "LOC-D-DC1"
  resource_group_name   = azurerm_resource_group.West_US_RG.name
  location              = azurerm_resource_group.West_US_RG.location
  size                  = "Standard_B2s"
  admin_username        = "adminuser"
  admin_password        = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.LOC-D-DC1-NIC.id]
  depends_on            = [azurerm_network_interface.LOC-D-DC1-NIC]

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

##########################
# Security               #
##########################

resource "azurerm_network_security_group" "EastUS-Sec-Group" {
  name                = "EastUS-Sec-Group"
  location            = azurerm_resource_group.East_US_RG.location
  resource_group_name = azurerm_resource_group.East_US_RG.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_application_security_group" "EastUS-appsecuritygroup" {
  name                = "EastUS-appsecuritygroup"
  location            = azurerm_resource_group.East_US_RG.location
  resource_group_name = azurerm_resource_group.East_US_RG.name

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_security_group" "WestUS-Sec-Group" {
  name                = "WestUS-Sec-Group"
  location            = azurerm_resource_group.West_US_RG.location
  resource_group_name = azurerm_resource_group.West_US_RG.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_application_security_group" "WestUS-appsecuritygroup" {
  name                = "WestUS-appsecuritygroup"
  location            = azurerm_resource_group.West_US_RG.location
  resource_group_name = azurerm_resource_group.West_US_RG.name

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet_network_security_group_association" "LOC-A-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.LOC-A-Subnet.id
  network_security_group_id = azurerm_network_security_group.EastUS-Sec-Group.id
}

resource "azurerm_subnet_network_security_group_association" "LOC-B-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.LOC-B-Subnet.id
  network_security_group_id = azurerm_network_security_group.EastUS-Sec-Group.id
}

resource "azurerm_subnet_network_security_group_association" "LOC-C-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.LOC-C-Subnet.id
  network_security_group_id = azurerm_network_security_group.WestUS-Sec-Group.id
}

resource "azurerm_subnet_network_security_group_association" "LOC-D-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.LOC-D-Subnet.id
  network_security_group_id = azurerm_network_security_group.WestUS-Sec-Group.id
}
