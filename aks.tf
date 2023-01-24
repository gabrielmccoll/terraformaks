resource "azurerm_resource_group" "example" {
  name     = "${var.clustername}-rg"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "example" {
  name                              = var.clustername
  location                          = azurerm_resource_group.example.location
  resource_group_name               = azurerm_resource_group.example.name
  dns_prefix                        = var.clustername
  automatic_channel_upgrade         = "patch"
  role_based_access_control_enabled = true
  sku_tier                          = "Free"


  network_profile {
    network_plugin     = "azure"
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    network_mode       = "transparent"
  }

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_B2s"
    enable_auto_scaling = true
    max_count           = 3
    min_count           = 1
    vnet_subnet_id      = azurerm_subnet.akspool.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Dev"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}