
resource "azurerm_automation_account" "aks" {
  name                = azurerm_container_registry.aks.name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Basic"
  tags = {
    environment = "development"
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "auto_aks" {
  role_definition_name = "Contributor"
  scope = azurerm_resource_group.example.id
  principal_id = azurerm_automation_account.aks.identity[0].principal_id
}


### Script you want to run, in my case to delete
data "local_file" "demo_ps1" {
    filename = "./runbooks/demo.ps1"
}

resource "azurerm_automation_runbook" "demo_rb" {
  name                = azurerm_container_registry.aks.name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.aks.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This Run Book is a demo"
  runbook_type            = "PowerShell"
  content                 = data.local_file.demo_ps1.content
}

### a Schedule and linking the schedule to the runbook
resource "azurerm_automation_schedule" "aks" {
  name                    = "delete the TF after x"
  resource_group_name = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.aks.name
  frequency               = "Hour"
  interval                = var.SelfDestructinHours
  timezone                = "UTC" 
  description             = "Run after X hour"
  start_time = timeadd(local.timenow, "${var.SelfDestructinHours}h")
  expiry_time = timeadd(local.timenow, "24h")
#  lifecycle {
#    ignore_changes = [
#      start_time
#    ]
#  }
}

resource "azurerm_automation_job_schedule" "demo_sched" {
  resource_group_name = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.aks.name
  schedule_name           = azurerm_automation_schedule.aks.name
  runbook_name            = azurerm_automation_runbook.demo_rb.name
#   depends_on = [azurerm_automation_schedule.sunday] this was to fix a bug that might be fixed by now
}

### adding in variables to pass to the scripts
resource "azurerm_automation_variable_string" "rgname" {
  name                    = "rgname"
  resource_group_name = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.aks.name
  value                   = azurerm_resource_group.example.name
}



