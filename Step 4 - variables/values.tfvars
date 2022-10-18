resource_group = {
  "rg_01" = "East US",
  "rg_02" = "East US"
}

virtual_network = {
  "vnet-01" = {
    address_space       = ["10.10.0.0/24"]
    location            = "East US"
    resource_group_name = "rg_01"
  },
  "vnet-02" = {
    address_space       = ["10.10.1.0/24"]
    location            = "East US"
    resource_group_name = "rg_01"
  },
  "vnet-03" = {
    address_space       = ["10.10.2.0/24"]
    location            = "East US"
    resource_group_name = "rg_02"
  },
  "vnet-04" = {
    address_space       = ["10.10.3.0/24"]
    location            = "East US"
    resource_group_name = "rg_02"
  }
}

azurerm_subnet = {
  "LOC-A-Subnet" = {
    name                 = "LOC-A-subnet"
    resource_group_name  = "rg_01"
    virtual_network_name = "vnet-01"
    address_prefixes     = ["10.10.0.0/24"]
  },
  "LOC-B-Subnet" = {
    name                 = "LOC-B-subnet"
    resource_group_name  = "rg_01"
    virtual_network_name = "vnet-02"
    address_prefixes     = ["10.10.1.0/24"]
  },
  "LOC-C-Subnet" = {
    name                 = "LOC-C-subnet"
    resource_group_name  = "rg_02"
    virtual_network_name = "vnet-03"
    address_prefixes     = ["10.10.2.0/24"]
  },
  "LOC-D-Subnet" = {
    name                 = "LOC-D-subnet"
    resource_group_name  = "rg_02"
    virtual_network_name = "vnet-04"
    address_prefixes     = ["10.10.3.0/24"]
  }
}

azurerm_network_interface = {
  "LOC-A-DC1-NIC" = {
    name                = "LOC-A-DC1-NIC"
    location            = "East US"
    resource_group_name = "rg_01"

    ip_configuration = {
      name                          = "EastUS-Network"
      snet                          = "LOC-A-Subnet"
      private_ip_address_allocation = "Dynamic"
    }
  },
  "LOC-B-DC1-NIC" = {
    name                = "LOC-B-DC1-NIC"
    location            = "East US"
    resource_group_name = "rg_01"

    ip_configuration = {
      name                          = "EastUS-Network"
      snet                          = "LOC-B-Subnet"
      private_ip_address_allocation = "Dynamic"
    }
  },
  "LOC-C-DC1-NIC" = {
    name                = "LOC-C-DC1-NIC"
    location            = "East US"
    resource_group_name = "rg_02"

    ip_configuration = {
      name                          = "EastUS-Network"
      snet                          = "LOC-C-Subnet"
      private_ip_address_allocation = "Dynamic"
    }
  },
  "LOC-D-DC1-NIC" = {
    name                = "LOC-D-DC1-NIC"
    location            = "East US"
    resource_group_name = "rg_02"

    ip_configuration = {
      name                          = "EastUS-Network"
      snet                          = "LOC-D-Subnet"
      private_ip_address_allocation = "Dynamic"
    }
  }
}

azurerm_windows_virtual_machine = {
  "LOC-A-DC1" = {
    name                  = "LOC-A-DC1"
    resource_group_name   = "rg_01"
    location              = "East US"
    size                  = "Standard_B2s"
    admin_username        = "adminuser"
    admin_password        = "1qaz2wsx!QAZ@WSX"
    NIC_name              = "LOC-A-DC1-NIC"
  
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "StandardSSD_LRS"
    }

    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
    }
  },
  "LOC-B-DC1" = {
    name                  = "LOC-B-DC1"
    resource_group_name   = "rg_01"
    location              = "East US"
    size                  = "Standard_B2s"
    admin_username        = "adminuser"
    admin_password        = "1qaz2wsx!QAZ@WSX"
    NIC_name              = "LOC-B-DC1-NIC"
  
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "StandardSSD_LRS"
    }

    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
    }
  },
  "LOC-C-DC1" = {
    name                  = "LOC-C-DC1"
    resource_group_name   = "rg_02"
    location              = "East US"
    size                  = "Standard_B2s"
    admin_username        = "adminuser"
    admin_password        = "1qaz2wsx!QAZ@WSX"
    NIC_name              = "LOC-C-DC1-NIC"
  
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "StandardSSD_LRS"
    }

    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
    }
  },
  "LOC-D-DC1" = {
    name                  = "LOC-D-DC1"
    resource_group_name   = "rg_02"
    location              = "East US"
    size                  = "Standard_B2s"
    admin_username        = "adminuser"
    admin_password        = "1qaz2wsx!QAZ@WSX"
    NIC_name              = "LOC-D-DC1-NIC"
  
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "StandardSSD_LRS"
    }

    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
    }
  }
}

