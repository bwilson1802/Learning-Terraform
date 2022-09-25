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
resource "azurerm_resource_group" "Test_V1" {
  name     = "Test-V1"
  location = "East US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "Test_V1" {
  name                = "Test-V1-Network"
  resource_group_name = azurerm_resource_group.Test_V1.name
  location            = azurerm_resource_group.Test_V1.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "Test_V1_Subnet" {
  name                 = "Test-V1-subnet1"
  resource_group_name  = azurerm_resource_group.Test_V1.name
  virtual_network_name = azurerm_virtual_network.Test_V1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "Test_V1" {
  name                = "Test-V1-Security-Group1"
  location            = azurerm_resource_group.Test_V1.location
  resource_group_name = azurerm_resource_group.Test_V1.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "141.157.11.245/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "Test_V1" {
  subnet_id                 = azurerm_subnet.Test_V1_Subnet.id
  network_security_group_id = azurerm_network_security_group.Test_V1.id
}

resource "azurerm_public_ip" "Test_V1" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.Test_V1.name
  location            = azurerm_resource_group.Test_V1.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_interface" "Test_V1_NIC" {
  name                = "Test-nic"
  location            = azurerm_resource_group.Test_V1.location
  resource_group_name = azurerm_resource_group.Test_V1.name

  ip_configuration {
    name                          = "testconfig1"
    subnet_id                     = azurerm_subnet.Test_V1_Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Test_V1.id
  }
  tags = {
    enviornment = "dev"
  }
}

resource "azurerm_network_interface_security_group_association" "Test_V1" {
  network_interface_id      = azurerm_network_interface.Test_V1_NIC.id
  network_security_group_id = azurerm_network_security_group.Test_V1.id
}

resource "azurerm_linux_virtual_machine" "Test_V1_VM1" {
  name                  = "Linux-machine"
  resource_group_name   = azurerm_resource_group.Test_V1.name
  location              = azurerm_resource_group.Test_V1.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.Test_V1_NIC.id]

  custom_data = filebase64("customdata.tpl")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
        hostname = self.public_ip_address, 
        user = "adminuser",
        identityfile = "~/.ssh/textv1key"
  })
    interpreter = var.host_os == "windows" ? ["powershell", "-command"] : ["bash", "-c"]
  }

  tags = {
    enviornment = "dev"
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/testv1key.pub")
  }
}

data "azurerm_public_ip" "Test_V1_data" {
    name = azurerm_public_ip.Test_V1.name
    resource_group_name = azurerm_resource_group.Test_V1.name
}
  
output "public_ip_address" {
    value = "${azurerm_linux_virtual_machine.Test_V1_VM1.name}: ${data.azurerm_public_ip.Test_V1_data.ip_address}"
}

