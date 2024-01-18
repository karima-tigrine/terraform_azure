# 1 - Vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}


# subnet 
# 💡 Hint: Subnets divide a VNet IP address space into segments. Each subnet can have its own security and network settings.

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}


# Crete netwrok interface
#💡 Hint: Think of a network interface as a virtual network card. It’s the interplay between hardware and the Azure VNet.

resource "azurerm_network_interface" "nic" {
  name                = "example-nic"
  location            =  var.location
  resource_group_name =  var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a Network Security Group (NSG)
#########💡 Hint: NSGs are used to control inbound and outbound traffic to network interfaces (NIC), VMs, and subnets.

resource "azurerm_network_security_group" "nsg" {
  name                = "example-nsg"
  location            = var.location
  resource_group_name = "karima-tigrine"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "AppOnPort5000"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# Challenge 6: Link the NSG to the NIC

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


# Configure a Load Balancer
# 💡 Hint: Load balancers distribute incoming internet traffic across multiple servers, ensuring that if one server fails, the traffic will be rerouted to another healthy server. This enhances the availability and fault tolerance of your application.

# Step 1: Create a Public IP

resource "azurerm_public_ip" "lb_pubip" {
  name                = "example-lb-pubip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = "${var.resource_group_name}terraformdns"
}
#💡 Hint: This creates a public IP resource in Azure. The dynamic allocation method means that Azure will allocate the IP for you.

# Step 2: Set Up the Load Balancer

resource "azurerm_lb" "example_lb" {
  name                = "example-lb"
  location            = var.location
  resource_group_name = "karima-tigrine"

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pubip.id
  }
}

# 💡 Hint: The frontend_ip_configuration block ties the public IP to the load balancer’s frontend. Incoming traffic will hit this IP.

# Step 3: Load Balancer Backend Address Pool
# The backend address pool is an important component of the load balancer. The backend pool defines the group of resources that will serve traffic for a given load-balancing rule.


resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.example_lb.id
  name            = "backendAddressPool"
}

# 💡 Hint: Think of the backend address pool as the group of servers waiting to serve incoming requests.

# Step 4: Associate NIC to Backend Address Pool
# Connect the network interface of our VM to the backend address pool of our load balancer. Use a azurerm_network_interface_backend_address_pool_association

resource "azurerm_network_interface_backend_address_pool_association" "nic_to_backendpool" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}
#💡 Hint: This association allows the traffic reaching our load balancer to be forwarded to our VM through the network interface.

# Step 5: Load Balancer Rule
# Rules define how traffic is distributed to the VMs (through the backend pool). Here, we’re setting a rule for port 5000. Use a azurerm_lb_rule

resource "azurerm_lb_rule" "lb_rule_5000" {
  loadbalancer_id               = azurerm_lb.example_lb.id
  name                          = "Port5000Access"
  protocol                      = "Tcp"
  frontend_port                 = 5000
  backend_port                  = 5000
  frontend_ip_configuration_name = "publicIPAddress"
  backend_address_pool_ids      = [azurerm_lb_backend_address_pool.backend_pool.id]
}

# 💡 Hint: This rule is telling Azure: “Any traffic coming on port 5000 of the public IP 
# should be distributed to the VMs in the backend pool on their port 5000”.



