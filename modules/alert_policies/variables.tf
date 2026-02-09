variable "project_id" {
  description = "The project ID to deploy to."
  type        = string
}

variable "csv_path" {
  description = "Path to the CSV file containing alert policies data."
  type        = string
}

variable "moogsoft_url" {
  description = "The URL for the Moogsoft webhook notification channel."
  type        = string
  default     = "https://api.moogsoft.ai/v1/integrations/events"
}

variable "moogsoft_token" {
  description = "The token for the Moogsoft webhook notification channel."
  type        = string
  sensitive   = true
}
