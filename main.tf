###################################
# Test script, Do not add to repo #
# Password hardcoded in           #
# Networking                      #
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
# RTR VM                 #
##########################

resource "azurerm_windows_virtual_machine" "RTR" {
  name                = "RTR-VM"
  resource_group_name = azurerm_resource_group.Demo-RG.name
  location            = azurerm_resource_group.Demo-RG.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.Demo-Network.id, azurerm_network_interface.LON-Subnet.id]

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
# RTR network breakout   #
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

###################
# RTR - Internet  #
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
  depends_on = [azurerm_network_interface.RTR-Pub-NIC]
  
  tags = {
    environment = "Dev"
  }
}

resource "azurerm_public_ip" "RTR-Pub-Network" {
  name                = "RTR-Pub-Network"
  resource_group_name = azurerm_resource_group.Demo-RG.name
  location            = azurerm_resource_group.Demo-RG.location
  allocation_method   = "Dynamic"
  depends_on = [azurerm_network_interface.RTR-Pub-NIC]
  
  tags = {
    environment = "Dev"
  }
}

###################
# RTR-LON         #
###################

resource "azurerm_network_interface" "RTR-LON-NIC" {
  name                = "RTR-LON-NIC"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "RTR-LON-Network"
    subnet_id                     = azurerm_subnet.LON-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Demo-Network.id
  }
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_application_security_group" "RTR-LON-appsecuritygroup" {
  name                = "RTR-LON-appsecuritygroup"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name
  depends_on = [azurerm_network_interface.RTR-LON-NIC]
  
  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "LON-Subnet" {
  name                 = "LON-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.1.0/26"]
  depends_on = [azurerm_network_interface.RTR-LON-NIC]
}

resource "azurerm_network_security_group" "RTR-LON-Sec-Group" {
  name                = "RTR-LON-Sec-Group"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name
  depends_on = [azurerm_network_interface.RTR-LON-NIC]

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

###################
# RTR-NA          #
###################

resource "azurerm_network_interface" "RTR-NA-NIC" {
  name                = "RTR-NA-NIC"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "RTR-NA-Network"
    subnet_id                     = azurerm_subnet.NA-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Demo-Network.id
  }
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_application_security_group" "RTR-NA-appsecuritygroup" {
  name                = "RTR-NA-appsecuritygroup"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name
  depends_on = [azurerm_network_interface.RTR-NA-NIC]
  
  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "NA-Subnet" {
  name                 = "NA-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.2.0/26"]
  depends_on = [azurerm_network_interface.RTR-NA-NIC]
}

resource "azurerm_network_security_group" "RTR-NA-Sec-Group" {
  name                = "RTR-NA-Sec-Group"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name
  depends_on = [azurerm_network_interface.RTR-NA-NIC]

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

###################
# RTR-PAC          #
###################

resource "azurerm_network_interface" "RTR-PAC-NIC" {
  name                = "RTR-PAC-NIC"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name

  ip_configuration {
    name                          = "RTR-PAC-Network"
    subnet_id                     = azurerm_subnet.PAC-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Demo-Network.id
  }
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_application_security_group" "RTR-PAC-appsecuritygroup" {
  name                = "RTR-PAC-appsecuritygroup"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name
  depends_on = [azurerm_network_interface.RTR-PAC-NIC]
  
  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "PAC-Subnet" {
  name                 = "PAC-subnet"
  resource_group_name  = azurerm_resource_group.Demo-RG.name
  virtual_network_name = azurerm_virtual_network.Demo-Network.name
  address_prefixes     = ["10.10.3.0/26"]
  depends_on = [azurerm_network_interface.RTR-PAC-NIC]
}

resource "azurerm_network_security_group" "RTR-PAC-Sec-Group" {
  name                = "RTR-PAC-Sec-Group"
  location            = azurerm_resource_group.Demo-RG.location
  resource_group_name = azurerm_resource_group.Demo-RG.name
  depends_on = [azurerm_network_interface.RTR-PAC-NIC]

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


