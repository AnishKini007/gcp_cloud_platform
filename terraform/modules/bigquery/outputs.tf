output "dataset_id" {
  description = "BigQuery dataset ID"
  value       = google_bigquery_dataset.main.dataset_id
}

output "dataset_self_link" {
  description = "BigQuery dataset self link"
  value       = google_bigquery_dataset.main.self_link
}

output "service_account_email" {
  description = "BigQuery service account email"
  value       = google_service_account.bigquery.email
}
