# Monitoring Module

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

variable "notification_email" {
  description = "Email for monitoring notifications"
  type        = string
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
  type        = string
}
