resource_group = {
    "rg_01" = {
  name = rg_01
  location = "East US"
  }

"rg_02" = {
  name = rg_02
  location = "East US"
  }

}

virtual_network = {
    "vnet-01" = {
        address_space       = ["10.10.0.0/24"]
        location            = "East US"
        resource_group_name = "East_US_RG"
    },

    "vnet-02" = {
        address_space       = ["10.10.1.0/24"]
        location            = "East US"
        resource_group_name = "East_US_RG"
    },

    "vnet-03" = {
        address_space       = ["10.10.2.0/24"]
        location            = "East US"
        resource_group_name = "East_US_RG"
    },

    "vnet-04" = {
        address_space       = ["10.10.3.0/24"]
        location            = "East US"
        resource_group_name = "East_US_RG"
    }
}



