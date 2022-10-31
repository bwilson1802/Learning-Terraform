

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
# GC9-Net            #
##########################

resource "azurerm_resource_group" "GC9-East-US-RG" {
  name     = "GC9-East-US-RG"
  location = "East US"
}

resource "azurerm_virtual_network" "GC9-VNET" {
  name                = "GC9-VNET"
  resource_group_name = azurerm_resource_group.GC9-East-US-RG.name
  location            = azurerm_resource_group.GC9-East-US-RG.location
  address_space       = ["10.10.0.0/16"]
  depends_on          = [azurerm_resource_group.GC9-East-US-RG]
}

resource "azurerm_subnet" "GC9-Subnet" {
  name                 = "GC9-subnet"
  resource_group_name  = azurerm_resource_group.GC9-East-US-RG.name
  virtual_network_name = azurerm_virtual_network.GC9-VNET.name
  address_prefixes     = ["10.10.0.0/24"]
  depends_on           = [azurerm_virtual_network.GC9-VNET]
}

##########################
# GC9-DC1              #
##########################

resource "azurerm_network_interface" "CG9-DC1-NIC" {
  name                = "GC9-DC1-NIC"
  location            = azurerm_resource_group.GC9-East-US-RG.location
  resource_group_name = azurerm_resource_group.GC9-East-US-RG.name
  depends_on          = [azurerm_subnet.GC9-Subnet]

  ip_configuration {
    name                          = "CG9-VNET"
    subnet_id                     = azurerm_subnet.GC9-Subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    enviornment = "GC9"
  }
}

resource "azurerm_windows_virtual_machine" "GC9-DC1" {
  name                  = "GC9-DC1"
  resource_group_name   = azurerm_resource_group.GC9-East-US-RG.name
  location              = azurerm_resource_group.GC9-East-US-RG.location
  size                  = "Standard_B2s"
  admin_username        = "adminuser"
  admin_password        = "1qaz2wsx!QAZ@WSX"
  network_interface_ids = [azurerm_network_interface.CG9-DC1-NIC.id]
  depends_on            = [azurerm_network_interface.CG9-DC1-NIC]

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

# Each Vnet gets a sec group
resource "azurerm_network_security_group" "CG9-Sec-Group" {
  
  name                = "CG9-Sec-Group"
  location            = azurerm_resource_group.GC9-East-US-RG.location
  resource_group_name = azurerm_resource_group.GC9-East-US-RG.name
  depends_on          = [azurerm_windows_virtual_machine.GC9-DC1]

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Each RG gets an app security group
resource "azurerm_application_security_group" "GC9-appsecuritygroup" {
  
  name                = "GC9-appsecuritygroup"
  location            = azurerm_resource_group.GC9-East-US-RG.location
  resource_group_name = azurerm_resource_group.GC9-East-US-RG.name
  depends_on          = [azurerm_windows_virtual_machine.GC9-DC1]

  tags = {
    environment = "GC9"
  }
}

# Each subnet gets an association 
resource "azurerm_subnet_network_security_group_association" "GC9-Subnet-Sec-Group" {
  
  subnet_id                 = azurerm_subnet.GC9-Subnet.id
  network_security_group_id = azurerm_network_security_group.CG9-Sec-Group.id
  depends_on                = [azurerm_application_security_group.GC9-appsecuritygroup]
}

resource "random_string" "Rand" {
  length  = 8
  special = false
  upper   = false
}

output "resource_code" {
  value = random_string.Rand.result
}

# Generate random text for a unique storage account name
resource "random_id" "Rand-01" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "GC9-East-US-RG"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "GC9storageaccount-01" {
  name                     = "diag${random_id.Rand-01.hex}"
  resource_group_name      = "GC9-East-US-RG"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = [azurerm_application_security_group.GC9-appsecuritygroup]

  tags = {
    environment = "GC9"
  }
}

variable "location" {
  default = [
    "East US"
  ]
}

resource "azurerm_network_watcher" "GC9-Watcher-East-US" {
  name                = "GC9-Watcher-East-US"
  location            = azurerm_resource_group.GC9-East-US-RG.location
  resource_group_name = azurerm_resource_group.GC9-East-US-RG.name
}