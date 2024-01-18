terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
  tenant_id = "8f70a7b2-0cbf-47c1-8766-a7b63eb0078c"
  subscription_id = "9be192d5-330e-4755-94e3-a48142278016"
}
