terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatepgagi"
    container_name       = "terraform"
    key                  = "infra.tfstate"
  }
}
