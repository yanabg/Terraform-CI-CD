terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.13.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "StorageRG"
    storage_account_name = "taskboardstorageybg"
    container_name = "taskboardstorageybg"
    key = "terraform.tfstate"
  }
}


provider "azurerm" {
  subscription_id = "52e0804b-5a1d-46df-b6f0-98f99f90a383"
  features {

  }
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "yanarg" {
  name = "${var.resource_group_name}-${random_integer.ri.result}"
  #name = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_service_plan" "yanasp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  location            = azurerm_resource_group.yanarg.location
  resource_group_name = azurerm_resource_group.yanarg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "yanalwa" {
  name                = "${var.web_app_service_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.yanarg.name
  location            = azurerm_resource_group.yanarg.location
  service_plan_id     = azurerm_service_plan.yanasp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserverybg.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.ybgdatabase.name};User ID=${azurerm_mssql_server.sqlserverybg.administrator_login};Password=${azurerm_mssql_server.sqlserverybg.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

resource "azurerm_mssql_server" "sqlserverybg" {
  name                         = "${var.sql_server_name}-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.yanarg.name
  location                     = azurerm_resource_group.yanarg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_user
  administrator_login_password = var.sql_admin_user_pass
}

resource "azurerm_mssql_database" "ybgdatabase" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.sqlserverybg.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  zone_redundant = false
  sku_name       = "S0"
}

resource "azurerm_mssql_firewall_rule" "firewallybg" {
  name             = var.firewall_rule
  server_id        = azurerm_mssql_server.sqlserverybg.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "github" {
  app_id                 = azurerm_linux_web_app.yanalwa.id
  repo_url               = var.github_repo
  branch                 = "main"
  use_manual_integration = true
}