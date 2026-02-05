locals {
  uptime_checks_raw = csvdecode(file(var.csv_path))

  uptime_checks = [for c in local.uptime_checks_raw : {
    name            = c.name
    type            = upper(c.type)
    host            = c.host
    path            = try(c.path, "") != "" ? c.path : "/"
    port            = try(c.port, "") != "" ? tonumber(c.port) : (upper(c.type) == "HTTPS" ? 443 : 80)
    timeout         = try(c.timeout, "") != "" ? c.timeout : "10s"
    period          = try(c.period, "") != "" ? c.period : "60s"
    content_match   = try(c.content_match, "") != "" ? c.content_match : ""
    content_matcher = try(c.content_matcher, "") != "" ? c.content_matcher : "CONTAINS_STRING"
  }]
}

resource "google_monitoring_notification_channel" "moogsoft_webhook" {
  project      = var.project_id
  display_name = "Moogsoft Webhook"
  type         = "webhook_tokenauth"
  labels = {
    url = var.moogsoft_url
  }
  sensitive_labels {
    auth_token = var.moogsoft_token
  }
}

resource "google_monitoring_uptime_check_config" "bulk_checks" {
  for_each     = { for c in local.uptime_checks : c.name => c }
  project      = var.project_id
  display_name = each.value.name
  timeout      = each.value.timeout
  period       = each.value.period

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = each.value.host
    }
  }

  dynamic "http_check" {
    for_each = contains(["HTTP", "HTTPS"], each.value.type) ? [1] : []
    content {
      path         = each.value.path
      port         = each.value.port
      use_ssl      = each.value.type == "HTTPS"
      validate_ssl = each.value.type == "HTTPS"
    }
  }

  dynamic "tcp_check" {
    for_each = each.value.type == "TCP" ? [1] : []
    content {
      port = each.value.port
    }
  }

  dynamic "content_matchers" {
    for_each = each.value.content_match != "" ? [1] : []
    content {
      content = each.value.content_match
      matcher = each.value.content_matcher
    }
  }
}

resource "google_monitoring_alert_policy" "uptime_alerts" {
  for_each     = google_monitoring_uptime_check_config.bulk_checks
  project      = var.project_id
  display_name = "Uptime Failure - ${each.value.display_name}"
  combiner     = "OR"

  notification_channels = [google_monitoring_notification_channel.moogsoft_webhook.name]

  conditions {
    display_name = "Uptime Check failed for ${each.value.display_name}"
    condition_threshold {
      filter          = format("metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id=\"%s\"", each.value.uptime_check_id)
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1

      trigger {
        count = 1
      }

      aggregations {
        alignment_period     = "1200s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.label.*"]
      }
    }
  }

  documentation {
    content   = <<EOT
Alert Triggered: $${policy.display_name}
Host: $${resource.labels.host}
Project: $${resource.labels.project_id}
EOT
    mime_type = "text/markdown"
  }
}
