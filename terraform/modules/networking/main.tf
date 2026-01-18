# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-vpc-${var.environment}"
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Reserve IP range for Cloud SQL private service connection
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.project_name}-private-ip-${var.environment}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# Create private VPC connection for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Primary Subnet (Mumbai)
resource "google_compute_subnetwork" "primary" {
  name          = "${var.project_name}-subnet-primary-${var.environment}"
  ip_cidr_range = "10.0.0.0/20"
  region        = "asia-south1"
  network       = google_compute_network.vpc.id
  project       = var.project_id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.4.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.8.0.0/20"
  }

  private_ip_google_access = true
}

# Secondary Subnet (Singapore)
resource "google_compute_subnetwork" "secondary" {
  name          = "${var.project_name}-subnet-secondary-${var.environment}"
  ip_cidr_range = "10.1.0.0/20"
  region        = "asia-southeast1"
  network       = google_compute_network.vpc.id
  project       = var.project_id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.12.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.16.0.0/20"
  }

  private_ip_google_access = true
}

# Cloud Router for NAT (Primary)
resource "google_compute_router" "router_primary" {
  name    = "${var.project_name}-router-primary-${var.environment}"
  region  = "asia-south1"
  network = google_compute_network.vpc.id
  project = var.project_id
}

# Cloud NAT (Primary)
resource "google_compute_router_nat" "nat_primary" {
  name                               = "${var.project_name}-nat-primary-${var.environment}"
  router                             = google_compute_router.router_primary.name
  region                             = google_compute_router.router_primary.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project_id

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Cloud Router for NAT (Secondary)
resource "google_compute_router" "router_secondary" {
  name    = "${var.project_name}-router-secondary-${var.environment}"
  region  = "asia-southeast1"
  network = google_compute_network.vpc.id
  project = var.project_id
}

# Cloud NAT (Secondary)
resource "google_compute_router_nat" "nat_secondary" {
  name                               = "${var.project_name}-nat-secondary-${var.environment}"
  router                             = google_compute_router.router_secondary.name
  region                             = google_compute_router.router_secondary.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project_id

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall Rules - Allow internal communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-allow-internal-${var.environment}"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}

# Firewall Rules - Allow SSH from IAP
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.project_name}-allow-iap-ssh-${var.environment}"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

# Firewall Rules - Allow health checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.project_name}-allow-health-checks-${var.environment}"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
}
