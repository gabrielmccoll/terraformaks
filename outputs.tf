output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}

# output "identity" {
#   value     = azurerm_kubernetes_cluster.example.kubelet_identity[0].user_assigned_identity_id
#   sensitive = true
# }

