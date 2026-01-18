# Notification Channels
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification Channel"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = var.notification_email
  }
}

# Alert Policy - High CPU Usage
resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "${var.project_name} - High CPU Usage"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "CPU usage above 80%"

    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert Policy - High Memory Usage
resource "google_monitoring_alert_policy" "high_memory" {
  display_name = "${var.project_name} - High Memory Usage"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Memory usage above 85%"

    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/container/memory/used_bytes\" AND resource.type=\"k8s_container\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.85

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

# Alert Policy - Pod Restarts
resource "google_monitoring_alert_policy" "pod_restarts" {
  display_name = "${var.project_name} - Frequent Pod Restarts"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Pod restart count > 5 in 10 minutes"

    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/container/restart_count\" AND resource.type=\"k8s_container\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 5

      aggregations {
        alignment_period   = "600s"
        per_series_aligner = "ALIGN_DELTA"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

# Alert Policy - API Latency
resource "google_monitoring_alert_policy" "api_latency" {
  display_name = "${var.project_name} - High API Latency"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "API latency above 500ms"

    condition_threshold {
      filter          = "metric.type=\"loadbalancing.googleapis.com/https/backend_latencies\" AND resource.type=\"https_lb_rule\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 500

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_95"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["resource.backend_name"]
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

# Alert Policy - Error Rate
resource "google_monitoring_alert_policy" "error_rate" {
  display_name = "${var.project_name} - High Error Rate"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Error rate above 5%"

    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/error_count\" AND resource.type=\"k8s_container\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.05

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

# Alert Policy - Cloud SQL Connections
resource "google_monitoring_alert_policy" "sql_connections" {
  display_name = "${var.project_name} - High Cloud SQL Connections"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Cloud SQL connections above 80"

    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/postgresql/num_backends\" AND resource.type=\"cloudsql_database\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 80

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

# Alert Policy - Disk Usage
resource "google_monitoring_alert_policy" "disk_usage" {
  display_name = "${var.project_name} - High Disk Usage"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Disk usage above 85%"

    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/disk/utilization\" AND resource.type=\"gce_instance\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.85

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

# SLO - API Availability
resource "google_monitoring_slo" "api_availability" {
  service      = google_monitoring_custom_service.main.service_id
  project      = var.project_id
  display_name = "API Availability SLO"
  slo_id       = "${var.project_name}-api-availability"

  goal                = 0.999
  rolling_period_days = 30

  request_based_sli {
    good_total_ratio {
      total_service_filter = "metric.type=\"loadbalancing.googleapis.com/https/request_count\" AND resource.type=\"https_lb_rule\""
      good_service_filter  = "metric.type=\"loadbalancing.googleapis.com/https/request_count\" AND resource.type=\"https_lb_rule\" AND metric.response_code_class=\"2xx\""
    }
  }
}

# Custom Service for SLOs
resource "google_monitoring_custom_service" "main" {
  service_id   = "${var.project_name}-service"
  display_name = "${var.project_name} Service"
  project      = var.project_id
}

# Dashboard
resource "google_monitoring_dashboard" "main" {
  dashboard_json = jsonencode({
    displayName = "${var.project_name} Dashboard"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          width  = 6
          height = 4
          widget = {
            title = "CPU Usage"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_MEAN"
                    }
                  }
                }
              }]
            }
          }
        },
        {
          width  = 6
          height = 4
          xPos   = 6
          widget = {
            title = "Memory Usage"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/container/memory/used_bytes\" AND resource.type=\"k8s_container\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_MEAN"
                    }
                  }
                }
              }]
            }
          }
        }
      ]
    }
  })
  project = var.project_id
}
