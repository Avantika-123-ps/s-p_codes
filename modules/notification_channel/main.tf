locals {
  notifications_rows = csvdecode(file(var.notifications_csv_path))

  # Build normalized/clean rows
  rows = [
    for r in local.notifications_rows : {
      type        = lower(trimspace(try(r.type, "")))
      name        = trimspace(try(r.name, ""))
      email       = lower(trimspace(try(r.email, "")))
      url         = trimspace(try(r.url, ""))
      username    = trimspace(try(r.username, ""))
      secret_name = trimspace(try(r.secret_name, "")) # This secret will now contain the secret resource name without the version
    }
    if contains(["email", "webhook"], lower(trimspace(try(r.type, ""))))
  ]

  emails = toset([
    for r in local.rows : r.email
    if r.type == "email" && r.email != ""
  ])

  webhooks_by_url = {
    for r in local.rows :
    lower(r.url) => {
      url         = r.url
      name        = r.name != "" ? r.name : r.url
      username    = r.username
      secret_name = r.secret_name # This secret will now contain the secret resource name without the version
    }
    if r.type == "webhook" && r.url != ""
  }
}

# Data source to fetch secrets from Secret Manager
# This will fetch the "username:password" string
data "google_secret_manager_secret_version" "webhook_credentials" {
  for_each = {
    for k, v in local.webhooks_by_url :
    k => v.secret_name if v.secret_name != ""
  }
  # CORRECTED: The 'secret' argument expects the full secret resource name,
  # WITHOUT the version part. The provider will append '/versions/latest' automatically.
  secret = each.value # each.value now contains "projects/PROJECT_NUMBER/secrets/SECRET_ID"
}

resource "google_monitoring_notification_channel" "emails" {
  for_each     = local.emails
  project      = var.project_id
  display_name = "Email ${each.value}"
  type         = "email"
  labels = {
    email_address = each.value
  }
}

resource "google_monitoring_notification_channel" "webhooks" {
  for_each     = local.webhooks_by_url
  project      = var.project_id
  display_name = "Webhook ${each.value.name}"
  type         = "webhook_basicauth"

  labels = {
    url      = each.value.url
    username = each.value.secret_name != "" ? split(":", data.google_secret_manager_secret_version.webhook_credentials[each.key].secret_data)[0] : ""
  }

  sensitive_labels {
    password = each.value.secret_name != "" ? split(":", data.google_secret_manager_secret_version.webhook_credentials[each.key].secret_data)[1] : ""
  }
}
