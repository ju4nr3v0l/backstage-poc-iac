resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.aks_cluster_name

  default_node_pool {
    name           = "agentpool"
    node_count     = var.agent_count
    vm_size        = var.agent_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id
    os_disk_size_gb = 30
    type           = "VirtualMachineScaleSets"
    max_pods       = 110
  }

  identity {
    type = "SystemAssigned"
  }

  # Habilitar RBAC (antes: role_based_access_control)
  rbac_enabled = true

  network_profile {
    network_plugin  = "azure"
    network_policy  = "calico"       # opcional: Calico para políticas de red
    service_cidr    = "10.0.2.0/24"
    dns_service_ip  = "10.0.2.10"
    # docker_bridge_cidr ya no es soportado; Azure asigna automáticamente el bridge
  }

  tags = {
    environment = "poc"
    owner       = "JuanDavid"
  }
}
