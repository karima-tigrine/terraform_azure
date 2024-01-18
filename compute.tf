resource "azurerm_linux_virtual_machine" "vm" {
  name                = "example-vm"
  resource_group_name = "karima-tigrine"
  location            = "francecentral"
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "password321!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  custom_data = base64encode(file("${path.module}/config.sh"))


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "public_ip_loadbalancer" {
  value = azurerm_public_ip.lb_pubip.id
  description = "The private IP address of the newly created Azure VM"
}