# Cloud Storage Buckets

# Application data bucket
resource "google_storage_bucket" "app_data" {
  name          = "${var.project_id}-${var.project_name}-data-${var.environment}"
  location      = var.region
  project       = var.project_id
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Backup bucket
resource "google_storage_bucket" "backups" {
  name          = "${var.project_id}-${var.project_name}-backups-${var.environment}"
  location      = var.region
  project       = var.project_id
  storage_class = "NEARLINE"

  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Logs bucket
resource "google_storage_bucket" "logs" {
  name          = "${var.project_id}-${var.project_name}-logs-${var.environment}"
  location      = var.region
  project       = var.project_id
  storage_class = "STANDARD"

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Artifacts bucket (for CI/CD)
resource "google_storage_bucket" "artifacts" {
  name          = "${var.project_id}-${var.project_name}-artifacts-${var.environment}"
  location      = var.region
  project       = var.project_id
  storage_class = "STANDARD"

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
