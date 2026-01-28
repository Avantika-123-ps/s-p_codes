resource "random_string" "suffix" {
  for_each = { for bucket in var.buckets_list : bucket.name => bucket }

  length  = 4
  upper   = false
  special = false
}

module "log_export" {
  source   = "terraform-google-modules/log-export/google"
  version  = "~> 7.0"

  for_each = { for bucket in var.buckets_list : bucket.name => bucket if try(bucket.log_sink_name, "") != "" }

  # Construct the destination URI manually since we are using the raw resource
  destination_uri      = "logging.googleapis.com/${google_logging_project_bucket_config.destination[each.key].name}"
  filter               = try(each.value.filter, "")
  log_sink_name        = "${each.value.log_sink_name}_${random_string.suffix[each.key].result}"
  parent_resource_id   = try(each.value.parent_resource_id, var.project_id)
  parent_resource_type = try(each.value.parent_resource_type, "project")
  include_children     = true
  unique_writer_identity = true
}

resource "google_logging_project_bucket_config" "destination" {
  for_each = { for bucket in var.buckets_list : bucket.name => bucket }

  # Prepend projects/ to avoid 404, ignore changes to avoid inconsistent plan
  project        = "projects/${var.project_id}"
  location       = each.value.location
  bucket_id      = each.value.name
  retention_days = try(each.value.retention_days, null)

  lifecycle {
    ignore_changes = [project]
  }
}

resource "google_project_iam_member" "log_writer" {
  for_each = module.log_export

  project = var.project_id
  role    = "roles/logging.bucketWriter"
  member  = each.value.writer_identity
}
