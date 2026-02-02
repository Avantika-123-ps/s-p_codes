variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "buckets_list" {
  description = "List of maps containing bucket configuration."
  type = list(object({
    name                 = string
    location             = string
    versioning           = bool
    log_sink_name        = optional(string)
    retention_days       = optional(number)
    filter               = optional(string)
    parent_resource_id   = optional(string)
    parent_resource_type = optional(string)
    groups               = optional(list(string), [])
  }))
}
