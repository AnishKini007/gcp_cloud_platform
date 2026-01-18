output "topic_names" {
  description = "Pub/Sub topic names"
  value = {
    events        = google_pubsub_topic.events.name
    notifications = google_pubsub_topic.notifications.name
    dead_letter   = google_pubsub_topic.dead_letter.name
  }
}

output "service_account_email" {
  description = "Pub/Sub service account email"
  value       = google_service_account.pubsub.email
}
