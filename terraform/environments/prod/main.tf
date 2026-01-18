# Main Terraform configuration - Production Environment

locals {
  common_labels = {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.project_name
  }
}

# Enable required GCP APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "bigquery.googleapis.com",
    "storage-api.googleapis.com",
    "pubsub.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
    "clouddeploy.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
  ])

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  project_name  = var.project_name
  
  depends_on = [google_project_service.required_apis]
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  project_id   = var.project_id
  environment  = var.environment
  project_name = var.project_name
  
  depends_on = [google_project_service.required_apis]
}

# Primary GKE Cluster
module "gke_primary" {
  source = "../../modules/gke"

  project_id         = var.project_id
  region             = var.region
  environment        = var.environment
  project_name       = var.project_name
  network_name       = module.networking.network_name
  subnet_name        = module.networking.primary_subnet_name
  
  cluster_name       = "${var.project_name}-primary"
  is_primary         = true
  
  depends_on = [module.networking, module.iam]
}

# Secondary GKE Cluster (for HA)
module "gke_secondary" {
  source = "../../modules/gke"

  project_id         = var.project_id
  region             = var.secondary_region
  environment        = var.environment
  project_name       = var.project_name
  network_name       = module.networking.network_name
  subnet_name        = module.networking.secondary_subnet_name
  
  cluster_name       = "${var.project_name}-secondary"
  is_primary         = false
  
  depends_on = [module.networking, module.iam]
}

# Primary Cloud SQL
module "cloud_sql_primary" {
  source = "../../modules/cloud-sql"

  project_id       = var.project_id
  region           = var.region
  environment      = var.environment
  project_name     = var.project_name
  network_id       = module.networking.network_id
  
  instance_name    = "${var.project_name}-primary"
  is_primary       = true
  
  depends_on = [module.networking]
}

# Replica Cloud SQL (for HA)
module "cloud_sql_replica" {
  source = "../../modules/cloud-sql"

  project_id          = var.project_id
  region              = var.secondary_region
  environment         = var.environment
  project_name        = var.project_name
  network_id          = module.networking.network_id
  
  instance_name       = "${var.project_name}-replica"
  is_primary          = false
  master_instance     = module.cloud_sql_primary.instance_name
  
  depends_on = [module.cloud_sql_primary]
}

# BigQuery Module
module "bigquery" {
  source = "../../modules/bigquery"

  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  project_name = var.project_name
  
  depends_on = [google_project_service.required_apis]
}

# Cloud Storage Module
module "storage" {
  source = "../../modules/storage"

  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  project_name = var.project_name
  
  depends_on = [google_project_service.required_apis]
}

# Pub/Sub Module
module "pubsub" {
  source = "../../modules/pubsub"

  project_id   = var.project_id
  environment  = var.environment
  project_name = var.project_name
  
  depends_on = [google_project_service.required_apis]
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  project_id          = var.project_id
  environment         = var.environment
  project_name        = var.project_name
  notification_email  = var.notification_email
  
  gke_cluster_name    = module.gke_primary.cluster_name
  
  depends_on = [module.gke_primary]
}
