locals {
  buckets_data = csvdecode(file("${path.module}/buckets.csv"))
}

module "log_infrastructure" {
  source = "../../modules/log_infrastructure"

  project_id = var.project_id

  buckets_list = [for b in local.buckets_data : {
    name          = b.name
    location      = b.location
    versioning    = tobool(b.versioning)
    log_sink_name = try(b.log_sink_name, null)
  }]
}

variable "project_id" {
  description = "The project ID to deploy to."
  type        = string
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }



provider "google" {
  project = var.project_id
}
