variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}

variable "location" {
  description = "Región donde desplegar"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
  default     = "RG-poc-iac"
}

variable "vnet_name" {
  description = "Nombre de la VNet"
  type        = string
  default     = "vnet-poc-iac"
}

variable "subnet_name" {
  description = "Nombre del Subnet para AKS"
  type        = string
  default     = "snet-aks"
}

variable "aks_cluster_name" {
  description = "Nombre del cluster AKS"
  type        = string
  default     = "CK-poc-iac"
}

variable "agent_count" {
  description = "Número de nodos"
  type        = number
  default     = 1
}

variable "agent_vm_size" {
  description = "Tamaño de VM para los nodos"
  type        = string
  default     = "standard_a2_v2"
}
