output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = module.gke_primary.cluster_name
}

output "gke_cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke_primary.cluster_endpoint
  sensitive   = true
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL connection name"
  value       = module.cloud_sql_primary.connection_name
}

output "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = module.bigquery.dataset_id
}

output "pubsub_topic_names" {
  description = "Pub/Sub topic names"
  value       = module.pubsub.topic_names
}

output "storage_bucket_names" {
  description = "Cloud Storage bucket names"
  value       = module.storage.bucket_names
}
