terraform {
    required_version = ">=0.14.9"

    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 2.26"
        }
    }
}

provider "azurerm" {
    skip_provider_registration = false
    features {}
}

resource "azurerm_resource_group" "gr" {
  name     = "Trabalho_Leonardo_Vinissius"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.gr.location
  resource_group_name = azurerm_resource_group.gr.name

  depends_on = [
    azurerm_resource_group.gr
  ]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.gr.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.0.2.0/24"]

  depends_on = [
    azurerm_resource_group.gr,
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_public_ip" "example" {
  name                = "ipPublico"
  resource_group_name = azurerm_resource_group.gr.name
  location            = azurerm_resource_group.gr.location
  allocation_method   = "Static"

  tags = {
    environment = "Test"
  }
}

resource "azurerm_network_security_group" "secgrupo" {
  name                = "secgrupo"
  location            = azurerm_resource_group.gr.location
  resource_group_name = azurerm_resource_group.gr.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "MYSQL"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "Apache"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "vIntnet"
  location            = azurerm_resource_group.gr.location
  resource_group_name = azurerm_resource_group.gr.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.12"
    public_ip_address_id          = azurerm_public_ip.example.id
  }

  depends_on = [    azurerm_resource_group.gr, 
                    azurerm_subnet.internal, 
                    azurerm_public_ip.example 
  ]
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.secgrupo.id

  depends_on = [
    azurerm_network_interface.main,
    azurerm_network_security_group.secgrupo
  ]
}

resource "azurerm_virtual_machine" "main" {
  name                  = "tfvl-vm"
  location              = azurerm_resource_group.gr.location
  resource_group_name   = azurerm_resource_group.gr.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "Principal"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false 
  }
  tags = {
    environment = "test"
  }
}

