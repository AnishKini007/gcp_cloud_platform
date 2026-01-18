output "bucket_names" {
  description = "Cloud Storage bucket names"
  value = {
    app_data  = google_storage_bucket.app_data.name
    backups   = google_storage_bucket.backups.name
    logs      = google_storage_bucket.logs.name
    artifacts = google_storage_bucket.artifacts.name
  }
}

output "app_data_bucket_url" {
  description = "App data bucket URL"
  value       = google_storage_bucket.app_data.url
}
