resource "azurerm_virtual_network" "aks" {
  name                = "${var.clustername}-vnet"
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "akspool" {
  name                 = "akspool"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.0.0.0/24"]
}