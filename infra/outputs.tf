output "kube_config" {
  description = "Kubeconfig para acceso al cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "ingress_ip" {
  description = "IP pública del Ingress Controller"
  value       = data.azurerm_public_ip.nginx_ingress.ip_address
}
