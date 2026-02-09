locals {
  alert_policies_raw = csvdecode(file(var.csv_path))

  alert_policies = [for p in local.alert_policies_raw : {
    name                = p.name
    type                = upper(p.type) # e.g., CPU, FILESYSTEM
    threshold           = try(tonumber(p.threshold), 80)
    duration            = try(p.duration, "300s")
    comparison          = try(p.comparison, "COMPARISON_GT")
    alignment_period    = try(p.alignment_period, "60s")
    per_series_aligner  = try(p.per_series_aligner, "ALIGN_MEAN")
    notifications       = try(split(",", p.notifications), ["moogsoft"])
    cross_series_reducer = try(p.cross_series_reducer, "REDUCE_MEAN")
    group_by_fields     = try(split(",", p.group_by_fields), ["resource.label.instance_id"])
    filter_custom       = try(p.filter_custom, "")
  }]
}

resource "google_monitoring_notification_channel" "moogsoft_webhook" {
  project      = var.project_id
  display_name = "Moogsoft Webhook Alert Policies"
  type         = "webhook_tokenauth"
  labels = {
    url = "$${var.moogsoft_url}?token=$${var.moogsoft_token}"
  }
}

resource "google_monitoring_alert_policy" "policies" {
  for_each     = { for p in local.alert_policies : p.name => p }
  project      = var.project_id
  display_name = each.value.name
  combiner     = "OR"

  # Map 'moogsoft' to the generic notification channel we define here.
  notification_channels = contains(each.value.notifications, "moogsoft") ? [google_monitoring_notification_channel.moogsoft_webhook.name] : []

  conditions {
    display_name = "$${each.value.type} usage policy for $${each.value.name}"
    
    condition_threshold {
      # Filter for CPU or File System usage. Defaults handle standard GCP metrics.
      # If custom filter is provided, use it, otherwise fall back to type-based logic.
      filter = each.value.filter_custom != "" ? each.value.filter_custom : (
        each.value.type == "CPU" ? 
        "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\"" : 
        # Fallback for FILESYSTEM
        "metric.type=\"compute.googleapis.com/guest/disk/bytes_used\" AND resource.type=\"gce_instance\" AND metric.labels.state=\"used\""
      )

      duration        = each.value.duration
      comparison      = each.value.comparison
      threshold_value = each.value.threshold / 100.0 # Standardize to a 0.0 - 1.0 limit

      trigger {
        count = 1
      }

      aggregations {
        alignment_period     = each.value.alignment_period
        per_series_aligner   = each.value.per_series_aligner
        cross_series_reducer = each.value.cross_series_reducer
        group_by_fields      = each.value.group_by_fields
      }
    }
  }

  documentation {
    content   = <<EOT
Alert Triggered: $$$${policy.display_name}
Threshold Crossed: $$$${condition.threshold_value}
Duration: $$$${condition.duration}
Severity: High
EOT
    mime_type = "text/markdown"
  }
}
