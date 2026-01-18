# Networking Module - VPC, Subnets, Firewall Rules

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The primary GCP region"
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
