variable "project_id" {
  description = "The project ID where resources will be created."
  type        = string
}

variable "csv_path" {
  description = "The path to the CSV file containing the uptime check definitions."
  type        = string
}

variable "moogsoft_url" {
  description = "The URL for the Moogsoft webhook."
  type        = string
  default     = "https://your-moogsoft-instance.com/webhook" # Provide a sensible default
}

variable "moogsoft_token" {
  description = "The authentication token for the Moogsoft webhook."
  type        = string
  sensitive   = true
}
