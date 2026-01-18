# Cloud SQL Module

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

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}

variable "is_primary" {
  description = "Whether this is the primary instance"
  type        = bool
  default     = true
}

variable "master_instance" {
  description = "Master instance name for read replicas"
  type        = string
  default     = ""
}

variable "database_version" {
  description = "Database version"
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "Machine type tier"
  type        = string
  default     = "db-custom-2-7680"
}
