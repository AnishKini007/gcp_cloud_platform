# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  # For replicas, set master_instance_name
  master_instance_name = var.is_primary ? null : var.master_instance

  settings {
    tier              = var.tier
    availability_type = var.is_primary ? "REGIONAL" : "ZONAL"
    disk_size         = 100
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    # Backup configuration (primary only)
    dynamic "backup_configuration" {
      for_each = var.is_primary ? [1] : []
      content {
        enabled                        = true
        start_time                     = "03:00"
        point_in_time_recovery_enabled = true
        transaction_log_retention_days = 7
        backup_retention_settings {
          retained_backups = 30
          retention_unit   = "COUNT"
        }
      }
    }

    # IP configuration
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
      ssl_mode        = "ENCRYPTED_ONLY"  # Require SSL for all connections
    }

    # Maintenance window (primary only - replicas inherit from master)
    dynamic "maintenance_window" {
      for_each = var.is_primary ? [1] : []
      content {
        day          = 7  # Sunday
        hour         = 3
        update_track = "stable"
      }
    }

    # Insights configuration
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    database_flags {
      name  = "max_connections"
      value = "100"
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }
  }

  deletion_protection = false  # Set to true in production
}

# Create database
resource "google_sql_database" "database" {
  count    = var.is_primary ? 1 : 0
  name     = "${var.project_name}_db"
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# Create database user
resource "google_sql_user" "users" {
  count    = var.is_primary ? 1 : 0
  name     = "${var.project_name}_user"
  instance = google_sql_database_instance.main.name
  password = random_password.db_password[0].result
  project  = var.project_id
}

# Generate random password
resource "random_password" "db_password" {
  count   = var.is_primary ? 1 : 0
  length  = 32
  special = true
}

# Store password in Secret Manager
resource "google_secret_manager_secret" "db_password" {
  count     = var.is_primary ? 1 : 0
  secret_id = "${var.instance_name}-password"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  count       = var.is_primary ? 1 : 0
  secret      = google_secret_manager_secret.db_password[0].id
  secret_data = random_password.db_password[0].result
}
