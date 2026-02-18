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
