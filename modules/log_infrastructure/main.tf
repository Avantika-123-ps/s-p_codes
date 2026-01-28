resource "random_string" "suffix" {
  for_each = { for bucket in var.buckets_list : bucket.name => bucket }

  length  = 4
  upper   = false
  special = false
}

resource "google_logging_project_sink" "log_export" {
  for_each = { for bucket in var.buckets_list : bucket.name => bucket if try(bucket.log_sink_name, "") != "" }

  name                   = "${each.value.log_sink_name}_${random_string.suffix[each.key].result}"
  destination            = "logging.googleapis.com/${google_logging_project_bucket_config.destination[each.key].name}"
  filter                 = try(each.value.filter, "")
  
  # Ensure project includes projects/ prefix and enable unique identity
  project                = coalesce(each.value.parent_resource_id, var.project_id)
  unique_writer_identity = true
}

resource "google_logging_project_bucket_config" "destination" {
  for_each = { for bucket in var.buckets_list : bucket.name => bucket }

  # Prepend projects/ to avoid 404, ignore changes to avoid inconsistent plan
  project        = var.project_id
  location       = each.value.location
  bucket_id      = each.value.name
  retention_days = try(each.value.retention_days, null)

  lifecycle {
    ignore_changes = [project]
  }
}

resource "google_project_iam_member" "log_writer" {
  for_each = google_logging_project_sink.log_export

  project = var.project_id
  role    = "roles/logging.bucketWriter"
  member  = coalesce(each.value.writer_identity, "serviceAccount:cloud-logs@system.gserviceaccount.com")
}
