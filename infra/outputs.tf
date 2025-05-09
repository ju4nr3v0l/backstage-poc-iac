output "kube_config" {
  description = "Kubeconfig para acceso al cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "ingress_ip" {
  description = "IP pública del Ingress Controller"
  value       = helm_release.nginx_ingress.status[0].load_balancer_ingress[0].ip
}
