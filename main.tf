provider "azurerm" {

  features = {}

}

 

resource "azurerm_resource_group" "rg" {

  name     = "rg-devops-mimm-env"

  location = "East US"  # Cambia la ubicación según tu preferencia

}

 

resource "azurerm_virtual_network" "vnet" {

  name                = "vnet-devops-mimm-env"

  address_space       = ["10.0.0.0/24"]  # Cambia el rango según tus necesidades

  location            = azurerm_resource_group.rg.location

  resource_group_name = azurerm_resource_group.rg.name

 

  subnet {

    name           = "subnet-devops-mimm-env"

    address_prefix = "10.0.0.0/24"  # Ajusta el rango de la subred según tus necesidades

  }

 

  subnet {

    name           = "subnet-jenkins"

    address_prefix = "10.0.1.0/28"  # Ajusta el rango de la subred de Jenkins según tus necesidades

  }

}

 

resource "azurerm_linux_virtual_machine" "vm" {

  name                = "mv-jenkins-mimm-dev"

  resource_group_name = azurerm_resource_group.rg.name

  location            = azurerm_resource_group.rg.location

  size                = "Standard_B2ms"

  admin_username      = "adminuser"

  admin_password      = "Password1234!"  # Cambia la contraseña según tus necesidades

 

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

    sku       = "20.04-LTS"

    version   = "latest"

  }

 

  provisioner "remote-exec" {

    inline = [

      "sudo apt update",

      "sudo apt install -y openjdk-11-jdk",

      "sudo apt install -y jenkins",

      "sudo systemctl enable jenkins",

      "sudo systemctl start jenkins",

    ]

  }

}

 

resource "azurerm_network_interface" "nic" {

  name                = "nic-jenkins-mimm-dev"

  resource_group_name = azurerm_resource_group.rg.name

 

  ip_configuration {

    name                          = "nicConfig"

    subnet_id                     = azurerm_subnet.subnet-jenkins.id

    private_ip_address_allocation = "Dynamic"

  }

}

 

resource "azurerm_subnet" "subnet-jenkins" {

  name                 = "subnet-jenkins"

  resource_group_name  = azurerm_resource_group.rg.name

  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes     = ["10.0.1.0/28"]
}
