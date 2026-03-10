# Lower-case keyed emails for case-insensitive lookups
output "email_channel_ids" {
  value = {
    for v in values(google_monitoring_notification_channel.emails) :
    lower(v.labels.email_address) => v.id
  }
}

# Keep by-url map (current behavior)
output "webhook_channel_ids" {
  value = {
    for k, v in google_monitoring_notification_channel.webhooks :
    k => v.id   # k is lower(url)
  }
}

# ➕ Add: by-name map, extracted from display_name "Webhook <name>"
# (Because for_each uses URL, we reconstruct the name we set)
output "webhook_channel_ids_by_name" {
  value = {
    for v in values(google_monitoring_notification_channel.webhooks) :
    replace(v.display_name, "Webhook ", "") => v.id
  }
}
