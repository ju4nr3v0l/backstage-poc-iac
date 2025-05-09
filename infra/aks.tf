resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.aks_cluster_name
  oidc_issuer_enabled = true

  default_node_pool {
    name            = "agentpool"
    node_count      = var.agent_count
    vm_size         = var.agent_vm_size
    vnet_subnet_id  = azurerm_subnet.aks.id
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
    max_pods        = 110
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"       # opcional: para aplicar políticas de red
    service_cidr   = "10.0.2.0/24"
    dns_service_ip = "10.0.2.10"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "poc"
    owner       = "JuanDavid"
  }
}
# karpenter identity
resource "azurerm_user_assigned_identity" "karpenter" {
  name                = "karpenter-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = {
    environment = "poc"
    owner       = "JuanDavid"
  }
}
resource "azurerm_role_assignment" "karpenter_vm_contributor" {
  scope                = azurerm_resource_group.rg.name != "" ? azurerm_resource_group.rg[0].id : data.azurerm_resource_group.existing_rg[0].id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}
# Crear la credencial federada
resource "azuread_application_federated_identity_credential" "karpenter" {
  application_object_id = data.azuread_user_assigned_identity.karpenter.principal_id
  issuer                = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject               = "system:serviceaccount:karpenter:karpenter"
  audiences             = ["api://AzureADTokenExchange"]
  display_name          = ""
}
