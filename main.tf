data "azurerm_client_config" "current" {}

data "azurerm_subnet" "default_subnet_data" {
  name                 = var.subnet1
  virtual_network_name = azurerm_virtual_network.Hub_Network.name
  resource_group_name  = azurerm_resource_group.RG.name 
}

resource "azurerm_resource_group" "RG" {
  name     = var.RG_name
  location = var.location
}

resource "azurerm_network_security_group" "Network_Security_Group" {
  name                = var.network_NSG
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  security_rule {
    name                       = var.security_rule_name
    priority                   = var.security_rule_priority
    direction                  = var.security_rule_direction
    access                     = var.security_rule_access
    protocol                   = var.security_rule_protocol
    source_port_range          = var.security_rule_source_port_range
    destination_port_range     = var.security_rule_destination_port_range
    source_address_prefix      = var.security_rule_source_address_prefix
    destination_address_prefix = var.security_rule_destination_address_prefix
  }
}

resource "azurerm_virtual_network" "Hub_Network" {
  name                = var.network_name
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  address_space       = var.address_space


  subnet {
    name           = var.subnet1
    address_prefix = var.subnet_address
    security_group = azurerm_network_security_group.Network_Security_Group.id
  }
  subnet {
    name           = var.subnet2
    address_prefix = var.subnet2_address
    security_group = azurerm_network_security_group.Network_Security_Group.id
  }
  tags = var.tags
}

resource "azurerm_public_ip" "linux1_pip" {
  name                = "${var.network_name}-linux1-pip"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = var.linux1_pip_allocation_method

  tags = var.tags
}

resource "azurerm_network_interface" "linux1_nic" {
  name                = "${var.network_NSG}-${var.subnet1}-vmnic"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.default_subnet_data.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux1_pip.id
  }
}

resource "azurerm_virtual_machine" "linux1" {
  name                  = "${var.network_name}-${var.subnet1}-linux1"
  location              = azurerm_resource_group.RG.location
  resource_group_name   = azurerm_resource_group.RG.name
  network_interface_ids = [azurerm_network_interface.linux1_nic.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = var.linux1_publisher
    offer     = var.linux1_offer
    sku       = var.linux1_sku
    version   = var.linux1_version
  }
  storage_os_disk {
    name              = "${var.network_name}-${var.subnet1}-Linux1-OS"
    caching           = var.linux1_storage_os_disk_caching
    create_option     = var.linux1_create_option
    managed_disk_type = var.linux1_managed_disk_type
  }
  os_profile {
    computer_name  = var.linux1_os_profile_computer_name
    admin_username = "azureuser"
    admin_password = "0987^%$#poiuYTRE" 
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = var.tags
}
