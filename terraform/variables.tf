variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "tenant_id" {
  type = string
}

variable "aks_name" {
  type    = string
  default = "devops-assignment-aks"
}

variable "acr_name" {
  type = string
}

variable "keyvault_name" {
  type = string
}
