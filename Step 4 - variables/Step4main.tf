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

resource "azurerm_resource_group" "rg" {
    for_each = var.resource_group 
  
    name     = each.key
    location = each.value
  }
  
  resource "azurerm_virtual_network" "VNET" {
    for_each = var.virtual_network
  
    name                = each.key
    resource_group_name = each.value.resource_group_name
    location            = each.value.location
    address_space       = each.value.address_space
  
  depends_on = [azurerm_resource_group.rg]
  }

  resource "azurerm_subnet" "Subnet" {
  for_each = var.subnet
  
  name                 = each.key
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.address_prefixes
  
  depends_on           = [azurerm_virtual_network.VNET]
}

resource "azurerm_network_interface" "NIC" {
  for_each = var.azurerm_network_interface

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  depends_on          = [azurerm_subnet.Subnet]

  ip_configuration {
    name                          = each.value.ip_configuration.name
    subnet_id                     = each.value.ip_configuration.subnet_id
    private_ip_address_allocation = each.value.ip_configuration.private_ip_address_allocation
  }

  tags = {
    enviornment = "dev"
  }
}