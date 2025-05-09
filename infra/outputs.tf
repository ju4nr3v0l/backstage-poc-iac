output "kube_config" {
  description = "Kubeconfig para acceso al cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "ingress_ip" {
  description = "IP pública del Ingress Controller"
  # status.0.load_balancer.0.ingress.0.ip según el esquema del provider k8s
  value       = data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip
}