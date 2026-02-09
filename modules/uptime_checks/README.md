# Uptime Checks Module Documentation

Module to create Google Cloud Monitoring Uptime Checks and Alert Policies in bulk via a CSV data structure.

## Overview
This module simplifies the creation of hundreds of uptime checks by passing them securely through a CSV configuration rather than repeating Terraform blocks.

The module natively deploys:
1. `google_monitoring_notification_channel` using `webhook_tokenauth` (Ideal for external webhooks like Moogsoft).
2. `google_monitoring_uptime_check_config` for HTTP, HTTPS, and TCP checks dynamically based on the input CSV. 
3. `google_monitoring_alert_policy` linking each individual check to the Notification Channel.

## Usage Example
```hcl
module "uptime_checks" {
  source = "../../modules/uptime_checks"

  project_id     = var.project_id
  csv_path       = "${path.module}/uptime_checks.csv"
  moogsoft_url   = "https://your-moogsoft-instance.com/webhook"
  moogsoft_token = var.moogsoft_token
}
```

## CSV Configuration Standard
The module strictly requires the CSV file to contain the headers below:
`name,type,host,path,port,timeout,period,content_match,content_matcher`

### Example Rows:
```csv
name,type,host,path,port,timeout,period,content_match,content_matcher
google-http,HTTP,www.google.com,/,80,10s,60s,google,CONTAINS_STRING
api-https,HTTPS,api.example.com,/health,443,10s,60s,,
db-tcp,TCP,10.0.0.5,,5432,10s,60s,,
```

### Field Definitions:
- **name**: Display name of the uptime check (and resulting Alert Policy).
- **type**: Protocol (`HTTP`, `HTTPS`, or `TCP`).
- **host**: The hostname or IP to check against.
- **path**: (HTTP/HTTPS only) Target path (default: `/`).
- **port**: Target port. (Defaults to 80 for HTTP, 443 for HTTPS if left explicitly blank).
- **timeout**: Max wait time (default: `10s`)
- **period**: How frequently to perform the check (default: `60s`).
- **content_match**: (Optional) Target string to look for in the body.
- **content_matcher**: Used with `content_match` (default: `CONTAINS_STRING`).

## Notification Channels / Filtering
* **Token Query Params:** The module formats your provided `moogsoft_token` into the query string of your webhook `moogsoft_url` automatically to comply with strict GCP API requirements for the `webhook_tokenauth` channel type.
* **Alert Restrictions:** The `alert_policy` conditions implement `resource.type="uptime_url"` explicitly, avoiding validation errors (`Field alert_policy.conditions[0].condition_threshold.filter had an invalid value`).

## Variable References
| Name             | Type      | Required | Description |
|------------------|-----------|----------|-------------|
| `project_id`     | `string`  | Yes      | The destination GCP project ID for resources |
| `csv_path`       | `string`  | Yes      | Path to the CSV definitions file |
| `moogsoft_url`   | `string`  | No       | External webhook URL (default: "https://your-moogsoft-instance.com/webhook") |
| `moogsoft_token` | `string`  | Yes      | Auth token appended securely to the webhook |
