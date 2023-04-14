resource "google_monitoring_alert_policy" "disk_alert" {
  combiner          = "OR"
  display_name      = "High Disk Usage"
  documentation {
    content = "This alert fires when the disk usage on the primary PostgreSQL instance goes above 85%."
  }

  conditions {
    display_name = "Disk Usage"
    condition_threshold {
      filter           = "metric.type=\"agent.googleapis.com/disk/percent_used\" AND resource.type=\"gce_instance\" AND resource.label.\"instance_id\"=\"${google_compute_instance.primary_db.self_link}\""
      duration         = "300s"
      comparison       = "COMPARISON_GT"
      threshold_value  = 85
      trigger {
        count = 1
      }
    }
  }
}

resource "google_monitoring_alert_policy" "cpu_alert" {
  combiner          = "OR"
  display_name      = "High CPU Usage Alert"
  documentation {
    content = "This alert fires when the CPU usage on the primary PostgreSQL instance goes above 90%."
  }
  conditions {
    display_name = "CPU Usage"
    condition_threshold {
      filter      = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\" AND resource.label.\"instance_id\"=\"${google_compute_instance.primary_db.self_link}\""
      duration    = "300s"
      comparison  = "COMPARISON_GT"
      threshold_value = 90
      trigger {
        count = 1
      }
    }
  }
}
