###################################
# Dev Test script,                #
# No Passwords                    #
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

# Create a resource group
resource "azurerm_resource_group" "Demo-RG" {
  name     = "Demo-RG"
  location = "East US"
}

##########################
# V net                  #
##########################

resource "azurerm_virtual_network" "Demo-Network" {
  name                = "Demo-Network"
  resource_group_name = azurerm_resource_group.Demo-RG.name
  location            = azurerm_resource_group.Demo-RG.location
  address_space       = ["10.10.0.0/16"]
}

###################
# Subnet          #
###################

resource "azurerm_subnet" "LOC-A-Subnet" {
  name                 = "LOC-A-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.0.0/24"]
}

resource "azurerm_subnet" "LOC-B-Subnet" {
  name                 = "LOC-B-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.1.0/24"]
  
}

resource "azurerm_subnet" "LOC-C-Subnet" {
  name                 = "LOC-C-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_subnet" "LOC-D-Subnet" {
  name                 = "LOC-D-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.3.0/24"]
}

##########################
# LOC-A-DC1              #
##########################

resource "azurerm_network_interface" "LOC-A-DC1-NIC" {
  name                = "LOC-A-DC1-NIC"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "Demo-Network"
    subnet_id                     = azurerm_subnet.LOC-A-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "Dynamic"
  }
  
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_windows_virtual_machine" "LOC-A-DC1" {
  name                = "LOC-A-DC1"
  resource_group_name = azurerm_resource_group.Demo-RG.name
  location            = azurerm_resource_group.Demo-RG.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.LOC-A-DC1-NIC.id]

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
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "LOC-B-Network"
    subnet_id                     = azurerm_subnet.LOC-B-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "Dynamic"
  }
  
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_windows_virtual_machine" "LOC-B-DC1" {
  name                = "LOC-B-DC1"
  resource_group_name = azurerm_resource_group.Demo-RG.name
  location            = azurerm_resource_group.Demo-RG.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.LOC-B-DC1-NIC.id]

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
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "LOC-C-Network"
    subnet_id                     = azurerm_subnet.LOC-C-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "Dynamic"
  }
  
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_windows_virtual_machine" "LOC-C-DC1" {
  name                = "LOC-C-DC1"
  resource_group_name = azurerm_resource_group.Demo-RG.name
  location            = azurerm_resource_group.Demo-RG.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.LOC-C-DC1-NIC.id]

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
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "LOC-D-Network"
    subnet_id                     = azurerm_subnet.LOC-D-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "Dynamic"
  }
  
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_windows_virtual_machine" "LOC-D-DC1" {
  name                = "LOC-D-DC1"
  resource_group_name = azurerm_resource_group.Demo-RG.name
  location            = azurerm_resource_group.Demo-RG.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.LOC-D-DC1-NIC.id]

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

resource "azurerm_network_security_group" "Demo-Sec-Group" {
  name                = "Demo-Sec-Group"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

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
resource "azurerm_application_security_group" "Demo-appsecuritygroup" {
  name                = "Demo-appsecuritygroup"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name
    
  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet_network_security_group_association" "LOC-A-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.LOC-A-Subnet.id
  network_security_group_id = azurerm_network_security_group.Demo-Sec-Group.id
}

resource "azurerm_subnet_network_security_group_association" "LOC-B-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.LOC-B-Subnet.id
  network_security_group_id = azurerm_network_security_group.Demo-Sec-Group.id
}

resource "azurerm_subnet_network_security_group_association" "LOC-C-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.LOC-C-Subnet.id
  network_security_group_id = azurerm_network_security_group.Demo-Sec-Group.id
}

resource "azurerm_subnet_network_security_group_association" "LOC-D-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.LOC-D-Subnet.id
  network_security_group_id = azurerm_network_security_group.Demo-Sec-Group.id
}