# BigQuery Dataset
resource "google_bigquery_dataset" "main" {
  dataset_id  = "${replace(var.project_name, "-", "_")}_${var.environment}"
  project     = var.project_id
  location    = var.region
  description = "Main analytics dataset for ${var.environment}"

  # Note: default_table_expiration_ms removed due to provider limitations
  # Set table expiration on individual tables instead

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  # Owner access for BigQuery service account
  access {
    role          = "OWNER"
    user_by_email = google_service_account.bigquery.email
  }

  # Default access - project readers
  access {
    role          = "READER"
    special_group = "projectReaders"
  }

  # Service account access will be granted via IAM instead
}

# BigQuery Tables
resource "google_bigquery_table" "events" {
  dataset_id = google_bigquery_dataset.main.dataset_id
  table_id   = "events"
  project    = var.project_id

  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "event_timestamp"
  }

  clustering = ["event_type", "user_id"]

  schema = jsonencode([
    {
      name        = "event_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Unique event identifier"
    },
    {
      name        = "event_type"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Type of event"
    },
    {
      name        = "user_id"
      type        = "STRING"
      mode        = "NULLABLE"
      description = "User identifier"
    },
    {
      name        = "event_timestamp"
      type        = "TIMESTAMP"
      mode        = "REQUIRED"
      description = "Event timestamp"
    },
    {
      name        = "event_data"
      type        = "JSON"
      mode        = "NULLABLE"
      description = "Event payload"
    }
  ])
}

resource "google_bigquery_table" "metrics" {
  dataset_id = google_bigquery_dataset.main.dataset_id
  table_id   = "metrics"
  project    = var.project_id

  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "metric_timestamp"
  }

  schema = jsonencode([
    {
      name        = "metric_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Unique metric identifier"
    },
    {
      name        = "metric_name"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Metric name"
    },
    {
      name        = "metric_value"
      type        = "FLOAT64"
      mode        = "REQUIRED"
      description = "Metric value"
    },
    {
      name        = "metric_timestamp"
      type        = "TIMESTAMP"
      mode        = "REQUIRED"
      description = "Metric timestamp"
    },
    {
      name        = "labels"
      type        = "JSON"
      mode        = "NULLABLE"
      description = "Metric labels"
    }
  ])
}

# Service Account for BigQuery
resource "google_service_account" "bigquery" {
  account_id   = "${var.project_name}-bq-sa-${var.environment}"
  display_name = "Service Account for BigQuery"
  project      = var.project_id
}

# IAM bindings
resource "google_project_iam_member" "bigquery" {
  for_each = toset([
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.bigquery.email}"
}
