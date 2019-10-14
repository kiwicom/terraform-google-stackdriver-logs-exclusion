// GCP Global Load Balancer
variable "exclude_glb_percent" {
  type        = number
  default     = 95
  description = "Percentage of GCP Global Load Balancer logs to be excluded"
}

variable "exclude_glb_severity_expression" {
  type        = string
  default     = "AND severity<ERROR"
  description = "Logs severity expression for GCP Global Load Balancer logs"
}

variable "exclude_glb_https_requests_only" {
  type        = bool
  default     = false
  description = "Set to true if you want to exclude only https requests"
}

// k8s non-system containers
variable "exclude_k8s_containers_namespace_whistelist" {
  type = list(string)
  default = [
    "kube-system",
    "system"
  ]
  description = "Kubernetes namespaces that are not excluded by k8s_containers expression rule"
}

variable "exclude_k8s_containers_percent" {
  type        = number
  default     = 100
  description = "Percentage of non-system k8s containers logs to be excluded"
}

variable "exclude_k8s_containers_severity_expression" {
  type        = string
  default     = "AND severity<ERROR"
  description = "Logs severity expression for non-system k8s containers logs"
}

// k8s system nginx
variable "exclude_k8s_system_nginx_percent" {
  type        = number
  default     = 100
  description = "Percentage of system nginx logs to be excluded"
}

variable "exclude_k8s_system_nginx_severity_expression" {
  type        = string
  default     = "AND severity<ERROR"
  description = "Logs severity expression for system nginx logs"
}
