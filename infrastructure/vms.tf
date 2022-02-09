resource "random_pet" "suffix" {
  length = 1
}

locals {
  backend_net_nsg = "backend-net-${random_pet.suffix.id}"
  backend_nic_nsg = "backend-nic-${random_pet.suffix.id}"
  backend_asg     = "backend-asg-${random_pet.suffix.id}"
  backend_vm      = "backend-${random_pet.suffix.id}"
}

resource "azurerm_network_security_group" "backend_net" {
  depends_on          = [module.install]
  name                = local.backend_net_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.resources.name
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  depends_on                = [module.install]
  subnet_id                 = local.backend_subnet_id
  network_security_group_id = azurerm_network_security_group.backend_net.id
}

resource "azurerm_network_security_group" "backend_nics" {
  depends_on          = [module.install]
  name                = local.backend_nic_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.resources.name
}

resource "azurerm_application_security_group" "backend_asg" {
  depends_on          = [module.install]
  name                = local.backend_asg
  location            = var.location
  resource_group_name = azurerm_resource_group.resources.name
}

resource "azurerm_network_interface" "backend" {
  depends_on          = [module.install]
  count               = var.backend_vm_count
  name                = "${local.backend_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.resources.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.backend_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "backend" {
  depends_on                = [module.install]
  count                     = var.backend_vm_count
  network_interface_id      = azurerm_network_interface.backend[count.index].id
  network_security_group_id = azurerm_network_security_group.backend_nics.id
}

resource "azurerm_network_interface_application_security_group_association" "backend" {
  depends_on                    = [module.install]
  count                         = var.backend_vm_count
  network_interface_id          = azurerm_network_interface.backend[count.index].id
  application_security_group_id = azurerm_application_security_group.backend_asg.id
}

resource "azurerm_availability_set" "backend" {
  depends_on                   = [module.install]
  name                         = local.backend_vm
  location                     = var.location
  resource_group_name          = azurerm_resource_group.resources.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

resource "azurerm_linux_virtual_machine" "backend" {
  depends_on          = [module.install]
  count               = var.backend_vm_count
  name                = "${local.backend_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.resources.name
  size                = var.backend_vm_size
  admin_username      = "azureuser"
  computer_name       = "backend-${count.index}"
  availability_set_id = azurerm_availability_set.backend.id
  network_interface_ids = [
    azurerm_network_interface.backend[count.index].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = module.install.public_key
  }

  # Using Standard SSD tier storage
  # Accepting the standard disk size from image
  # No data disk is being used
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  #Source image is hardcoded b/c I said so
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = merge(var.tags, var.backend_vm_tags)
}


# Inbound rules for backend subnet nsg
resource "azurerm_network_security_rule" "backend_net_22" {
  depends_on                                 = [module.install]
  name                                       = "allow_ssh"
  priority                                   = 100
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = "22"
  source_application_security_group_ids      = [module.install.worker_security_group_id]
  destination_application_security_group_ids = [azurerm_application_security_group.backend_asg.id]
  resource_group_name                        = azurerm_resource_group.resources.name
  network_security_group_name                = azurerm_network_security_group.backend_net.name
}

# Inbound rules for remote hosts

resource "azurerm_network_security_rule" "backend_nics_22" {
  depends_on                                 = [module.install]
  name                                       = "allow_ssh"
  priority                                   = 100
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = "22"
  source_application_security_group_ids      = [module.install.worker_security_group_id]
  destination_application_security_group_ids = [azurerm_application_security_group.backend_asg.id]
  resource_group_name                        = azurerm_resource_group.resources.name
  network_security_group_name                = azurerm_network_security_group.backend_nics.name
}

resource "azurerm_network_security_rule" "backend_nics_1433" {
  depends_on             = [module.install]
  name                   = "allow_mssql"
  priority               = 110
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "1433"
  source_application_security_group_ids = [
    module.install.worker_security_group_id,
    azurerm_application_security_group.backend_asg.id
  ]
  destination_address_prefix  = var.sql_service_tag
  resource_group_name         = azurerm_resource_group.resources.name
  network_security_group_name = azurerm_network_security_group.backend_nics.name
}