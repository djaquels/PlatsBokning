variable "db_password" {
    type = string
    description = "The password for the database"
    sensitive = true
}

variable "azure_db_password" {
    type = string
    description = "The password for the database"
    sensitive = true
}

variable "subscription_id" {
    type = string
    description = "The subscription id" 
    sensitive = true
}

provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
    name = "booking-desk-rg"
    location = "West Europe"
}

resource "azurerm_app_service_plan" "app_service_plan" {
    name = "booking-desk-app-service-plan"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku {
        tier = "Basic"
        size = "B1"
    }
}

# Database
resource "azurerm_postgresql_flexible_server" "db" {
    name = "appdb"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    administrator_login = "apiusser"
    administrator_password = var.db_password
    sku_name = "B_Standard_B1ms"
    storage_mb = 32768
    version = "14" 
    backup_retention_days = 7
    geo_redundant_backup_enabled = false
    public_network_access_enabled = true
}

# App Service
resource "azurerm_linux_web_app" "web_app" {
    name = "booking-desk-app"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id = azurerm_app_service_plan.app_service_plan.id
    
    site_config {
    
    }
    app_settings = {
        "RAILS_ENV" = "production"
        "DATABASE_URL" = "postgresql://apiusser:${var.db_password}@${azurerm_postgresql_flexible_server.db.fqdn}:5432/appdb"
        "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    }

    identity {
        type = "SystemAssigned"
    }
}

resource "azurerm_resource_group_template_deployment" "deployment" {
    name = "booking-desk-app-deployment"
    resource_group_name = azurerm_resource_group.rg.name
    deployment_mode = "Incremental"
    template_content = <<TEMPLATE
    {
        "resources":[
            {
                "type": "Microsoft.Web/sites/sourcecontrols",
                "apiVersion": "2022-03-01",
                "name": "${azurerm_linux_web_app.web_app.name}/web",
                "properties": {
                    "repoUrl": "https://github.com/djaquels/PlatsBokning.git",
                    "branch": "main",
                    "isManualIntegration": true
                }
            }
        ]
    }
    TEMPLATE
}