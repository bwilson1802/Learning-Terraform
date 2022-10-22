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

# 1 RG
resource "azurerm_resource_group" "rg" {

  name     = "rg_01"
  location = "East US"
}

# 3 VNETs
resource "azurerm_virtual_network" "VNET" {
  for_each = var.virtual_network

  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  address_space       = each.value.address_space

  depends_on = [azurerm_resource_group.rg]
}

# 3 subnets 
resource "azurerm_subnet" "Subnet" {
  for_each = var.azurerm_subnet

  name                 = each.key
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes

  depends_on = [azurerm_virtual_network.VNET]
}

# One NIC per VM
resource "azurerm_network_interface" "NIC" {
  for_each = var.azurerm_network_interface

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  depends_on          = [azurerm_subnet.Subnet]

  ip_configuration {
    name                          = each.value.ip_configuration.name
    subnet_id                     = azurerm_subnet.Subnet[each.value.ip_configuration.snet].id
    private_ip_address_allocation = each.value.ip_configuration.private_ip_address_allocation
  }

  tags = {
    enviornment = "dev"
  }
}

# 3 VMs 
resource "azurerm_windows_virtual_machine" "VM" {
  for_each = var.azurerm_windows_virtual_machine

  name                  = each.key
  resource_group_name   = each.value.resource_group_name
  location              = each.value.location
  size                  = each.value.size
  admin_username        = each.value.admin_username
  admin_password        = each.value.admin_password
  network_interface_ids = [azurerm_network_interface.NIC[each.value.NIC_name].id]
  depends_on            = [azurerm_network_interface.NIC]

  os_disk {
    caching              = each.value.os_disk.caching
    storage_account_type = each.value.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }

  tags = {
    enviornment = "dev"
  }
}

# Each Vnet gets a sec group
resource "azurerm_network_security_group" "Sec-Group" {
  for_each = var.azurerm_network_security_group

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  depends_on          = [azurerm_windows_virtual_machine.VM]

  security_rule {
    name                       = each.value.security_rule.name
    priority                   = each.value.security_rule.priority
    direction                  = each.value.security_rule.direction
    access                     = each.value.security_rule.access
    protocol                   = each.value.security_rule.protocol
    source_port_range          = each.value.security_rule.source_port_range
    destination_port_range     = each.value.security_rule.destination_port_range
    source_address_prefix      = each.value.security_rule.source_address_prefix
    destination_address_prefix = each.value.security_rule.destination_address_prefix
  }
}

# Each RG gets an app security group
resource "azurerm_application_security_group" "appsecuritygroup" {
  for_each = var.azurerm_application_security_group

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  depends_on          = [azurerm_windows_virtual_machine.VM]

  tags = {
    environment = "Dev"
  }
}

# Each subnet gets an association 
resource "azurerm_subnet_network_security_group_association" "Subnet-Sec-Group" {
  for_each = var.azurerm_subnet_network_security_group_association

  subnet_id                 = azurerm_subnet.Subnet[each.value.snet].id
  network_security_group_id = azurerm_network_security_group.Sec-Group[each.value.network_security_group_name].id
  depends_on                = [azurerm_application_security_group.appsecuritygroup]
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
    resource_group = "rg_01"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount-01" {
  name                     = "diag${random_id.Rand-01.hex}"
  resource_group_name      = "rg_01"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = [azurerm_application_security_group.appsecuritygroup]

  tags = {
    environment = "Dev"
  }
}

variable "location" {
  default = [
    "East US"
  ]
}

variable "vnet_address_space" {
  default = [
    "10.10.0.0/16",
    "10.10.1.0/16",
    "10.10.2.0/16"
  ]
}

resource "azurerm_virtual_network_peering" "Peering" {
  for_each = var.azurerm_virtual_network_peering
  
  name                      = each.key
  resource_group_name       = each.value.resource_group_name
  virtual_network_name      = each.value.virtual_network_name
  remote_virtual_network_id = azurerm_virtual_network.vnet[each.value.virtual_network].id
}

