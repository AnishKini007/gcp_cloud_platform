variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The primary GCP region"
  type        = string
  default     = "asia-south1"
}

variable "secondary_region" {
  description = "The secondary GCP region for HA"
  type        = string
  default     = "asia-southeast1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "gcp-platform"
}
