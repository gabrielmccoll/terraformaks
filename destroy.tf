module "destroy" {
  source              = "gabrielmccoll/selfdestruct/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  hours               = 6
  depends_on = [
    azurerm_resource_group.example
  ]
}

