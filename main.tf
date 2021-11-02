provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "examstor13" {
  name     = "examstor13-resources"
  location = "West Europe"
}
resource "azurerm_virtual_network" "examstor13" {
  name                = "virtnetname"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.examstor13.location
  resource_group_name = azurerm_resource_group.examstor13.name
}

resource "azurerm_subnet" "examstor13" {
  name                 = "subnetname"
  resource_group_name  = azurerm_resource_group.examstor13.name
  virtual_network_name = azurerm_virtual_network.examstor13.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}
resource "azurerm_storage_account" "examstor13" {
  name                = "examstor13"
  resource_group_name = azurerm_resource_group.examstor13.name

  location                 = azurerm_resource_group.examstor13.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.examstor13.id]
  }

  tags = {
    environment = "staging"
  }
}
resource "azurerm_advanced_threat_protection" "examstor13" {
  target_resource_id = azurerm_storage_account.examstor13.id
  enabled            = true
}
resource "azurerm_availability_set" "examstor13" {
  name                = "examstor13"
  location            = azurerm_resource_group.examstor13.location
  resource_group_name = azurerm_resource_group.examstor13.name

  tags = {
    environment = "Production"
  }
}
