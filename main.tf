terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
  cloud {
    organization = "flcdrg"
    workspaces {
      name = "terraform-appgw"
    }
  }
  required_version = ">= 1.2.3"
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "rg-terraform-appgw-australiaeast"
}
