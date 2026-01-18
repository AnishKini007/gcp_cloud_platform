# Pub/Sub Topics and Subscriptions

# Events topic
resource "google_pubsub_topic" "events" {
  name    = "${var.project_name}-events-${var.environment}"
  project = var.project_id

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  message_retention_duration = "86400s"  # 24 hours
}

# Events subscription
resource "google_pubsub_subscription" "events" {
  name    = "${var.project_name}-events-sub-${var.environment}"
  topic   = google_pubsub_topic.events.name
  project = var.project_id

  ack_deadline_seconds = 20

  message_retention_duration = "604800s"  # 7 days
  retain_acked_messages      = false

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = 5
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Notifications topic
resource "google_pubsub_topic" "notifications" {
  name    = "${var.project_name}-notifications-${var.environment}"
  project = var.project_id

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Notifications subscription
resource "google_pubsub_subscription" "notifications" {
  name    = "${var.project_name}-notifications-sub-${var.environment}"
  topic   = google_pubsub_topic.notifications.name
  project = var.project_id

  ack_deadline_seconds = 10

  push_config {
    push_endpoint = "https://example.com/push"  # Replace with actual endpoint

    oidc_token {
      service_account_email = google_service_account.pubsub.email
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Dead letter topic
resource "google_pubsub_topic" "dead_letter" {
  name    = "${var.project_name}-dead-letter-${var.environment}"
  project = var.project_id

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Dead letter subscription
resource "google_pubsub_subscription" "dead_letter" {
  name    = "${var.project_name}-dead-letter-sub-${var.environment}"
  topic   = google_pubsub_topic.dead_letter.name
  project = var.project_id

  ack_deadline_seconds       = 60
  message_retention_duration = "604800s"

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Service Account for Pub/Sub
resource "google_service_account" "pubsub" {
  account_id   = "${var.project_name}-pubsub-sa-${var.environment}"
  display_name = "Service Account for Pub/Sub"
  project      = var.project_id
}

# IAM bindings
resource "google_pubsub_topic_iam_member" "publisher" {
  project = var.project_id
  topic   = google_pubsub_topic.events.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.pubsub.email}"
}

resource "google_pubsub_subscription_iam_member" "subscriber" {
  project      = var.project_id
  subscription = google_pubsub_subscription.events.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.pubsub.email}"
}
