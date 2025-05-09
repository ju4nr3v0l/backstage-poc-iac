# 1) Obtenemos el nombre del node_resource_group generado por AKS
data "azurerm_kubernetes_cluster" "aks" {
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_resource_group.rg.name
}

# 2) Leemos el Public IP que Azure ya creó, con nombre fijo
data "azurerm_public_ip" "nginx_ingress" {
  name                = "nginx-ingress-pip"
  resource_group_name = data.azurerm_kubernetes_cluster.aks.node_resource_group
}
