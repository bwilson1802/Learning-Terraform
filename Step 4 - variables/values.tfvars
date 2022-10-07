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



