resource "azurerm_resource_group" "app" {
  name     = "rg-app"
  location = "Central India"
}

resource "azurerm_service_plan" "app_plan" {
  name                = "asp-devops-assignment"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  os_type  = "Linux"
  sku_name = "B1"
}
resource "azurerm_linux_web_app" "backend" {
  name                = "backend-devops-assignment"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  service_plan_id     = azurerm_service_plan.app_plan.id

  https_only = true

  site_config {
    always_on = true
  }

  app_settings = {
    ENVIRONMENT = "prod"
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
