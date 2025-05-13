resource "azurerm_public_ip" "nginx_ingress" {
  name                = "nginx-ingress-pip"
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  location            = azurerm_kubernetes_cluster.aks.location
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [helm_release.nginx_ingress]   # Helm se destruye primero
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.12.2"

  namespace        = "ingress-basic"
  create_namespace = true

  values = [
    yamlencode({
      controller = {
        replicaCount = 2
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/azure-pip-name" = "nginx-ingress-pip"
          }
        }
      }
    })
  ]
}
