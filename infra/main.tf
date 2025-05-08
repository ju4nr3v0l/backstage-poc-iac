resource "azurerm_resource_group" "rg_poc_iac" {
  name     = "RG-poc-iac"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks_ck_poc_iac" {
  name                = "CK-poc-iac"
  location            = azurerm_resource_group.rg_poc_iac.location
  resource_group_name = azurerm_resource_group.rg_poc_iac.name
  dns_prefix          = "pocaks"

  default_node_pool {
    name                = "pool1"
    node_count          = 2
    vm_size             = "Standard_DS2_v2"
    min_count           = 2
    max_count           = 5
  }

  identity {
    type = "SystemAssigned"
  }
}