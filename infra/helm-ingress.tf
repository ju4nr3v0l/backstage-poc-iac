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
