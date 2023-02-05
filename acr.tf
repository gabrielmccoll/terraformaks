resource "azurerm_container_registry" "aks" {
  name                = "azdpagentacr"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"

}
# to let the AKS cluster read from the container registry
# take note. there are multiple managed identities. this is for the node pool
#https://learn.microsoft.com/en-us/azure/aks/use-managed-identity#summary-of-managed-identities
resource "azurerm_role_assignment" "aks_acr" {
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.aks.id
  principal_id         = azurerm_kubernetes_cluster.example.kubelet_identity[0].object_id

}