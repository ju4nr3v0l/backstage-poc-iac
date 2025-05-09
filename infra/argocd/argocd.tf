#############################################
# 1. Namespace Argo CD
#############################################
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

#############################################
# 2. Helm Chart Argo CD
#############################################
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.46.6"                     # estable a mayo-2025
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      installCRDs = true
      server = {
        service = {
          type = "LoadBalancer"
          annotations = {
            # crea una IP pública con nombre fijo en el node RG
            "service.beta.kubernetes.io/azure-pip-name" = "argocd-server-pip"
          }
        }
        ingress = { enabled = false }            # aún sin DNS
      }
      configs = {
        secret = {
          # password admin bcryptada → "Admin123!"
          argocdServerAdminPassword = "$2a$10$HWsa3A9XyDYt2y57Q7LyvOrOAJr2MJbWxfNuQmzgOVLC6muX19e6m"
        }
      }
    })
  ]

  timeout    = 600
  depends_on = [helm_release.nginx_ingress]       # ya tienes NGINX instalado
}

#############################################
# 3. IP pública del Argo CD Server
#############################################

# (a) leer el node RG del AKS
data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}
# (b) leer la Public IP creada por la anotación
data "azurerm_public_ip" "argocd_lb_ip" {
  name                = "argocd-server-pip"
  resource_group_name = data.azurerm_kubernetes_cluster.aks.node_resource_group
  depends_on          = [helm_release.argocd]     # espera a que exista
}

output "argocd_public_ip" {
  description = "Argo CD UI → https://<IP>"
  value       = data.azurerm_public_ip.argocd_lb_ip.ip_address
}
