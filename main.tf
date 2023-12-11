provider "azurerm" {

  features = {}

}

 

resource "azurerm_resource_group" "rg" {

  name     = "myResourceGroup"

  location = "East US"

}

 

resource "azurerm_virtual_network" "vnet" {

  name                = "myVNet"

  address_space       = ["10.0.0.0/16"]

  location            = azurerm_resource_group.rg.location

  resource_group_name = azurerm_resource_group.rg.name

}

 

resource "azurerm_subnet" "subnet" {

  name                 = "mySubnet"

  resource_group_name  = azurerm_resource_group.rg.name

  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes     = ["10.0.1.0/24"]

}

 

resource "azurerm_network_interface" "nic" {

  name                = "myNIC"

  resource_group_name = azurerm_resource_group.rg.name

 

  ip_configuration {

    name                          = "myNICConfig"

    subnet_id                     = azurerm_subnet.subnet.id

    private_ip_address_allocation = "Dynamic"

  }

}

 

resource "azurerm_linux_virtual_machine" "vm" {

  name                = "myVM"

  resource_group_name = azurerm_resource_group.rg.name

  location            = azurerm_resource_group.rg.location

  size                = "Standard_DS1_v2"

  admin_username      = "adminuser"

  admin_password      = "Password1234!"

 

  network_interface_ids = [

    azurerm_network_interface.nic.id,

  ]

 

  os_disk {

    caching              = "ReadWrite"

    storage_account_type = "Standard_LRS"

  }

 

  source_image_reference {

    publisher = "Canonical"

    offer     = "UbuntuServer"

    sku       = "16.04-LTS"

    version   = "latest"

  }

}
