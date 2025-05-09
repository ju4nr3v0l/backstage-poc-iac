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

resource "azurerm_federated_identity_credential" "karpenter_federated_identity" {  
  name                = "KARPENTER_FID"  
  resource_group_name = azurerm_resource_group.karpenter_rg.name  
  audience            = ["api://AzureADTokenExchange"]  
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url  
  parent_id           = azurerm_user_assigned_identity.karpenter_identity.id  
  subject             = "system:serviceaccount:karpenter:karpenter"  
} 

resource "azurerm_role_assignment" "vm_contributor" {  
  scope                = azurerm_kubernetes_cluster.aks.node_resource_group_id  
  role_definition_name = "Virtual Machine Contributor"  
  principal_id         = azurerm_user_assigned_identity.karpenter_identity.principal_id  
}  

resource "azurerm_role_assignment" "network_contributor" {  
  scope                = azurerm_kubernetes_cluster.aks.node_resource_group_id  
  role_definition_name = "Network Contributor"  
  principal_id         = azurerm_user_assigned_identity.karpenter_identity.principal_id  
}  

resource "azurerm_role_assignment" "managed_identity_operator" {  
  scope                = azurerm_kubernetes_cluster.aks.node_resource_group_id  
  role_definition_name = "Managed Identity Operator"  
  principal_id         = azurerm_user_assigned_identity.karpenter_identity.principal_id  
}
