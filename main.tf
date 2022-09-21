###################################
# Dev Test script,                #
# Password hardcoded in           #
# Networking issues               #
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
# network breakout       #
##########################

# RTR LON-RTR-NIC 10.10.1.1, NA-RTR-NIC 10.10.2.1, PA-RTR-NIC 10.10.3.1, RTR-Internet
# azurerm_virtual_network, azurerm_network_security_group, azurerm_public_ip, azurerm_network_interface, and a azurerm_network_interface_security_group_association

resource "azurerm_virtual_network" "Demo-Network" {
  name                = "Demo-Network"
  resource_group_name = azurerm_resource_group.Demo-RG.name
  location            = azurerm_resource_group.Demo-RG.location
  address_space       = ["10.10.0.0/26"]
}

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

##########

resource "azurerm_public_ip" "RTR-Pub-Network" {
  name                = "RTR-Pub-Network"
  resource_group_name = azurerm_resource_group.Demo-RG.name
  location            = azurerm_resource_group.Demo-RG.location
  allocation_method   = "Dynamic"
    
  tags = {
    environment = "Dev"
  }
}

###################
# Subnet          #
###################

resource "azurerm_subnet" "RTR-Subnet" {
  name                 = "RTR-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.0.192/26"]
}

resource "azurerm_subnet_network_security_group_association" "RTR-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.RTR-Subnet.id
  network_security_group_id = azurerm_network_security_group.Demo-Sec-Group.id
}

############

resource "azurerm_subnet" "LON-Subnet" {
  name                 = "LON-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.0.0/26"]
  
}

resource "azurerm_subnet_network_security_group_association" "LON-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.LON-Subnet.id
  network_security_group_id = azurerm_network_security_group.Demo-Sec-Group.id
}

########

resource "azurerm_subnet" "NA-Subnet" {
  name                 = "NA-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.0.64/26"]
}

resource "azurerm_subnet_network_security_group_association" "NA-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.NA-Subnet.id
  network_security_group_id = azurerm_network_security_group.Demo-Sec-Group.id
}

########

resource "azurerm_subnet" "PAC-Subnet" {
  name                 = "PAC-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.0.128/26"]
}

resource "azurerm_subnet_network_security_group_association" "PAC-Subnet-Sec-Group" {
  subnet_id                 = azurerm_subnet.PAC-Subnet.id
  network_security_group_id = azurerm_network_security_group.Demo-Sec-Group.id
}

###################
# NIC             #
###################

resource "azurerm_network_interface" "RTR-Pub-NIC" {
  name                = "RTR-Pub-NIC"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "Demo-Network"
    subnet_id                     = azurerm_subnet.RTR-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.RTR-Pub-Network.id
  }
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_application_security_group" "RTR-appsecuritygroup" {
  name                = "RTR-appsecuritygroup"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  tags = {
    environment = "Dev"
  }
}

########## 

resource "azurerm_network_interface" "RTR-LON-NIC" {
  name                = "RTR-LON-NIC"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "RTR-LON-Network"
    subnet_id                     = azurerm_subnet.LON-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.RTR-Pub-Network.id
  }
  
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_application_security_group" "RTR-LON-appsecuritygroup" {
  name                = "RTR-LON-appsecuritygroup"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name
    
  tags = {
    environment = "Dev"
  }
}

##########

resource "azurerm_network_interface" "RTR-NA-NIC" {
  name                = "RTR-NA-NIC"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "RTR-NA-Network"
    subnet_id                     = azurerm_subnet.NA-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.RTR-Pub-Network.id
  }
  
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_application_security_group" "RTR-NA-appsecuritygroup" {
  name                = "RTR-NA-appsecuritygroup"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name
    
  tags = {
    environment = "Dev"
  }
}

##########

resource "azurerm_network_interface" "RTR-PAC-NIC" {
  name                = "RTR-PAC-NIC"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "RTR-PAC-Network"
    subnet_id                     = azurerm_subnet.PAC-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.RTR-Pub-Network.id
  }
  
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_application_security_group" "RTR-PAC-appsecuritygroup" {
  name                = "RTR-PAC-appsecuritygroup"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name
  
  tags = {
    environment = "Dev"
  }
}

##########################
# RTR VM                 #
##########################

resource "azurerm_windows_virtual_machine" "RTR" {
  name                = "RTR-VM"
  resource_group_name = azurerm_resource_group.Demo-RG.name
  location            = azurerm_resource_group.Demo-RG.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.RTR-Pub-NIC.id, azurerm_network_interface.RTR-NA-NIC.id, azurerm_network_interface.RTR-PAC-NIC.id, azurerm_network_interface.RTR-LON-NIC.id]

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
