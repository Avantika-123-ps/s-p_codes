resource "random_string" "suffix" {
  for_each = { for bucket in var.buckets_list : bucket.name => bucket }

  length  = 4
  upper   = false
  special = false
}

module "destination" {
  source   = "terraform-google-modules/log-export/google//modules/logbucket"
  version  = "~> 7.0"

  for_each = { for bucket in var.buckets_list : bucket.name => bucket }

  project_id     = var.project_id
  name           = each.value.name
  location       = each.value.location
  log_sink_writer_identity = "${module.log_export[each.key].writer_identity}"
  retention_days = try(each.value.retention_days, null)
}

module "log_export" {
  source   = "terraform-google-modules/log-export/google"
  version  = "~> 7.0"

  for_each = { for bucket in var.buckets_list : bucket.name => bucket if try(each.value.log_sink_name, "") != "" }

  destination_uri      = module.destination[each.key].destination_uri
  filter               = try(each.value.filter, "")
  log_sink_name        = "${each.value.log_sink_name}_${random_string.suffix[each.key].result}"
  parent_resource_id   = try(each.value.parent_resource_id, var.project_id)
  parent_resource_type = try(each.value.parent_resource_type, "project")
  include_children     = true
}


