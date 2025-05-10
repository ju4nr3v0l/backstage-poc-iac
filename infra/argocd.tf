# ##################################
# # Helm release Argo CD simplificada
# ##################################
# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   version          = "5.46.6"
#   namespace        = "argocd"
#   create_namespace = true         # Helm crea el NS
#
#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
#
#   # Exponer con LoadBalancer (sin DNS todavía)
#   set {
#     name  = "server.service.type"
#     value = "LoadBalancer"
#   }
#   set {
#     name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/azure-pip-name"
#     value = "argocd-server-pip"
#   }
#
#   timeout = 1200
#
# }