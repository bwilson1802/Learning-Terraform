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
  }
  "LOC-B-Subnet" = {
    name                 = "LOC-B-subnet"
    resource_group_name  = "rg_01"
    virtual_network_name = "vnet-02"
    address_prefixes     = ["10.10.1.0/24"]
  }
  "LOC-C-Subnet" = {
    name                 = "LOC-C-subnet"
    resource_group_name  = "rg_02"
    virtual_network_name = "vnet-03"
    address_prefixes     = ["10.10.3.0/24"]
  }
  "LOC-D-Subnet" = {
    name                 = "LOC-D-subnet"
    resource_group_name  = "rg_02"
    virtual_network_name = "vnet-04"
    address_prefixes     = ["10.10.4.0/24"]
  }
}
azurerm_network_interface = {
  "LOC-A-DC1-NIC" = {
    name                = "LOC-A-DC1-NIC"
    location            = "East US"
    resource_group_name = "rg_01"

    ip_configuration = {
      name                          = "EastUS-Network"
      subnet_id                     = "LOC-A-Subnet"
      private_ip_address_allocation = "Dynamic"
    }
  }
  "LOC-B-DC1-NIC" = {
    name                = "LOC-B-DC1-NIC"
    location            = "East US"
    resource_group_name = "rg_01"

    ip_configuration = {
      name                          = "EastUS-Network"
      subnet_id                     = "LOC-B-Subnet"
      private_ip_address_allocation = "Dynamic"
    }
  }
  "LOC-C-DC1-NIC" = {
    name                = "LOC-C-DC1-NIC"
    location            = "East US"
    resource_group_name = "rg_02"

    ip_configuration = {
      name                          = "EastUS-Network"
      subnet_id                     = "LOC-C-Subnet"
      private_ip_address_allocation = "Dynamic"
    }
  }
  "LOC-D-DC1-NIC" = {
    name                = "LOC-D-DC1-NIC"
    location            = "East US"
    resource_group_name = "rg_02"

    ip_configuration = {
      name                          = "EastUS-Network"
      subnet_id                     = "LOC-D-Subnet"
      private_ip_address_allocation = "Dynamic"
    }
  }
}