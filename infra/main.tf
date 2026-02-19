resource "azurerm_resource_group" "app" {
  name     = "rg-app"
  location = "Central India"
}

resource "azurerm_service_plan" "app_plan" {
  name                = "asp-devops-assignment"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  os_type  = "Linux"
  sku_name = "S1"
}
resource "azurerm_linux_web_app" "backend" {
  name                = "backend-devops-assignment"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  service_plan_id     = azurerm_service_plan.app_plan.id

  https_only = true
  public_network_access_enabled = false


  site_config {
    always_on = true
  }

  app_settings = {
    ENVIRONMENT = "prod"
  }
}
resource "azurerm_linux_web_app_slot" "backend_dev" {
  name           = "dev"
  app_service_id = azurerm_linux_web_app.backend.id

  site_config {}

  app_settings = {
    ENVIRONMENT = "dev"
  }
}

resource "azurerm_linux_web_app_slot" "backend_staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.backend.id

  site_config {}

  app_settings = {
    ENVIRONMENT = "staging"
  }
}


resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-app"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
}
resource "azurerm_subnet" "private_endpoint" {
  name                 = "snet-private-endpoint"
  resource_group_name  = azurerm_resource_group.app.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}
resource "azurerm_private_dns_zone" "appservice" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.app.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "appservice-dns-link"
  resource_group_name   = azurerm_resource_group.app.name
  private_dns_zone_name = azurerm_private_dns_zone.appservice.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "backend_pe" {
  name                = "pe-backend-app"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  subnet_id           = azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "psc-backend-app"
    private_connection_resource_id = azurerm_linux_web_app.backend.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.appservice.id
    ]
  }
}
resource "azurerm_linux_web_app" "frontend" {
  name                = "frontend-devops-assignment"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  service_plan_id     = azurerm_service_plan.app_plan.id

  https_only = true

  site_config {
    always_on = true
  }

  app_settings = {
    BACKEND_URL = "https://${azurerm_linux_web_app.backend.default_hostname}"
  }
}
resource "azurerm_linux_web_app_slot" "frontend_dev" {
  name           = "dev"
  app_service_id = azurerm_linux_web_app.frontend.id

  site_config {}

  app_settings = {
    ENVIRONMENT = "dev"
    BACKEND_URL = "https://${azurerm_linux_web_app.backend.default_hostname}"
  }
}

resource "azurerm_linux_web_app_slot" "frontend_staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.frontend.id

  site_config {}

  app_settings = {
    ENVIRONMENT = "staging"
    BACKEND_URL = "https://${azurerm_linux_web_app.backend.default_hostname}"
  }
}
