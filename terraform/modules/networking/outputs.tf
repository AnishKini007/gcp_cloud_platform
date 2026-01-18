output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "network_id" {
  description = "VPC network ID"
  value       = google_compute_network.vpc.id
}

output "network_self_link" {
  description = "VPC network self link"
  value       = google_compute_network.vpc.self_link
}

output "primary_subnet_name" {
  description = "Primary subnet name"
  value       = google_compute_subnetwork.primary.name
}

output "secondary_subnet_name" {
  description = "Secondary subnet name"
  value       = google_compute_subnetwork.secondary.name
}

output "primary_subnet_id" {
  description = "Primary subnet ID"
  value       = google_compute_subnetwork.primary.id
}

output "secondary_subnet_id" {
  description = "Secondary subnet ID"
  value       = google_compute_subnetwork.secondary.id
}

output "private_vpc_connection" {
  description = "Private VPC connection for Cloud SQL"
  value       = google_service_networking_connection.private_vpc_connection.network
}
