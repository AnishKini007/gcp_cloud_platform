# Service Accounts for Workload Identity

# API Service Account
resource "google_service_account" "api_service" {
  account_id   = "${var.project_name}-api-${var.environment}"
  display_name = "Service Account for API Service"
  project      = var.project_id
}

# Worker Service Account
resource "google_service_account" "worker_service" {
  account_id   = "${var.project_name}-worker-${var.environment}"
  display_name = "Service Account for Worker Service"
  project      = var.project_id
}

# Frontend Service Account
resource "google_service_account" "frontend" {
  account_id   = "${var.project_name}-frontend-${var.environment}"
  display_name = "Service Account for Frontend"
  project      = var.project_id
}

# Portal Service Account
resource "google_service_account" "portal" {
  account_id   = "${var.project_name}-portal-${var.environment}"
  display_name = "Service Account for Portal Dashboard"
  project      = var.project_id
}

# Cloud Build Service Account
resource "google_service_account" "cloud_build" {
  account_id   = "${var.project_name}-build-${var.environment}"
  display_name = "Service Account for Cloud Build"
  project      = var.project_id
}

# IAM Bindings for API Service
resource "google_project_iam_member" "api_service" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/pubsub.publisher",
    "roles/pubsub.subscriber",
    "roles/storage.objectViewer",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/secretmanager.secretAccessor",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.api_service.email}"
}

# IAM Bindings for Worker Service
resource "google_project_iam_member" "worker_service" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/pubsub.subscriber",
    "roles/storage.objectAdmin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/secretmanager.secretAccessor",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.worker_service.email}"
}

# IAM Bindings for Frontend
resource "google_project_iam_member" "frontend" {
  for_each = toset([
    "roles/storage.objectViewer",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.frontend.email}"
}

# IAM Bindings for Cloud Build
resource "google_project_iam_member" "cloud_build" {
  for_each = toset([
    "roles/container.developer",
    "roles/storage.admin",
    "roles/artifactregistry.writer",
    "roles/clouddeploy.operator",
    "roles/iam.serviceAccountUser",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

# Workload Identity Bindings
# Note: These will be created after GKE clusters are deployed
# The GKE cluster creates the Workload Identity pool needed for these bindings

# API Service
resource "google_service_account_iam_member" "api_workload_identity" {
  count              = var.enable_workload_identity ? 1 : 0
  service_account_id = google_service_account.api_service.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/api-service]"
}

# Worker Service
resource "google_service_account_iam_member" "worker_workload_identity" {
  count              = var.enable_workload_identity ? 1 : 0
  service_account_id = google_service_account.worker_service.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/worker-service]"
}

# Frontend
resource "google_service_account_iam_member" "frontend_workload_identity" {
  count              = var.enable_workload_identity ? 1 : 0
  service_account_id = google_service_account.frontend.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/frontend]"
}

# Portal
resource "google_service_account_iam_member" "portal_workload_identity" {
  count              = var.enable_workload_identity ? 1 : 0
  service_account_id = google_service_account.portal.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/portal]"
}

# Custom IAM Role for minimal permissions
resource "google_project_iam_custom_role" "app_minimal" {
  role_id     = "${replace(var.project_name, "-", "_")}_app_minimal_${var.environment}"
  title       = "Minimal Application Role"
  description = "Minimal permissions for application services"
  project     = var.project_id

  permissions = [
    "logging.logEntries.create",
    "monitoring.metricDescriptors.create",
    "monitoring.metricDescriptors.get",
    "monitoring.metricDescriptors.list",
    "monitoring.monitoredResourceDescriptors.get",
    "monitoring.monitoredResourceDescriptors.list",
    "monitoring.timeSeries.create",
  ]
}
