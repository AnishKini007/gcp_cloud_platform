output "api_service_account_email" {
  description = "API service account email"
  value       = google_service_account.api_service.email
}

output "worker_service_account_email" {
  description = "Worker service account email"
  value       = google_service_account.worker_service.email
}

output "frontend_service_account_email" {
  description = "Frontend service account email"
  value       = google_service_account.frontend.email
}

output "portal_service_account_email" {
  description = "Portal service account email"
  value       = google_service_account.portal.email
}

output "cloud_build_service_account_email" {
  description = "Cloud Build service account email"
  value       = google_service_account.cloud_build.email
}
