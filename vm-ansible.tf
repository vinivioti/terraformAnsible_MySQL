

resource "azurerm_public_ip" "exampleansible" {
  name                = "ipPublicoansible"
  resource_group_name = azurerm_resource_group.gr.name
  location            = azurerm_resource_group.gr.location
  allocation_method   = "Static"

  tags = {
    environment = "Test"
  }
}

resource "azurerm_network_interface" "mainansible" {
  name                = "vIntnetansible"
  location            = azurerm_resource_group.gr.location
  resource_group_name = azurerm_resource_group.gr.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.exampleansible.id
  }
}

resource "azurerm_network_interface_security_group_association" "exampleansible" {
  network_interface_id      = azurerm_network_interface.mainansible.id
  network_security_group_id = azurerm_network_security_group.secgrupo.id

  depends_on = [
    azurerm_network_interface.mainansible,
    azurerm_network_security_group.secgrupo
  ]
}

resource "azurerm_virtual_machine" "main_ansible" {
  name                  = "tfvmansible"
  location              = azurerm_resource_group.gr.location
  resource_group_name   = azurerm_resource_group.gr.name
  network_interface_ids = [azurerm_network_interface.mainansible.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk3"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "ansiblemachine"
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

resource "null_resource" "upload2"{
 triggers = {
   order = azurerm_virtual_machine.main_ansible.id
 }

  provisioner "file" {
    connection {
        type = "ssh"
        user = "testadmin"
        password = "Password1234!"
        host = azurerm_public_ip.exampleansible.ip_address
    }
    source = "ansible"
    destination = "/home/testadmin"
  }
}


resource "null_resource" "apt_ansible1"{
triggers = {
    order = null_resource.upload2.id
}

provisioner "remote-exec" {
    connection {
        type = "ssh"
        user = "testadmin"
        password = "Password1234!"
        host = azurerm_public_ip.exampleansible.ip_address
  
      }
inline = [
    "sudo apt-get update",
    "sudo apt-get install -y software-properties-common",
    "sudo apt-add-repository --yes --update ppa:ansible/ansible",
    "sudo apt-get -y install python3 ansible",
   
  
    ]
  }
}

resource "null_resource" "run_ansible1"{
triggers = {
    order = null_resource.apt_ansible1.id
}

provisioner "remote-exec" {
    connection {
        type = "ssh"
        user = "testadmin"
        password = "Password1234!"
        host = azurerm_public_ip.exampleansible.ip_address
  
      }
inline = [
  
    "ansible-playbook -i /home/testadmin/ansible/inventario /home/testadmin/ansible/playbook.yaml"
  
    ]
  }
}

