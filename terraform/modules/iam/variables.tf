# IAM Module - Service Accounts and Workload Identity

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity bindings (requires GKE cluster to exist)"
  type        = bool
  default     = false
}
