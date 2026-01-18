# GKE Cluster Module

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
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

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "is_primary" {
  description = "Whether this is the primary cluster"
  type        = bool
  default     = true
}

variable "min_nodes" {
  description = "Minimum number of nodes per zone"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes per zone"
  type        = number
  default     = 5
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-standard-4"
}
