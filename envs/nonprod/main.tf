locals {
  buckets_data = csvdecode(file("${path.module}/buckets.csv"))
}

module "log_infrastructure" {
  source = "../../modules/log_infrastructure"

  project_id   = var.project_id

  buckets_list = [for b in local.buckets_data : {
    name                 = b.name
    location             = b.location
    versioning           = tobool(b.versioning)
    log_sink_name        = try(b.log_sink_name, null)
    retention_days       = try(tonumber(b.retention_days), null)
    filter               = try(b.filter, null)
    parent_resource_id = try(b.parent_resource_id, null)
    parent_resource_type = try(b.parent_resource_type, null)
    groups               = try(split(",", b.group_id), [])
  }]
}

variable "project_id" {
  description = "The project ID to deploy to."
  type        = string
}

module "uptime_checks" {
  source = "../../modules/uptime_checks"

  project_id     = var.project_id
  csv_path       = "${path.module}/uptime_checks.csv"
  moogsoft_token = "dummy-token-for-testing" # In practice, this should come from a secret manager
}

module "my_monitoring_dashboard" {
  source = "../../modules/dashboard"
  project_id = var.project_id
}
