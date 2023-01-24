resource "azurerm_container_registry" "aks" {
  name                = "azdpagentacr"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"

}