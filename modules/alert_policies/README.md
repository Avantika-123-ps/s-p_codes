# Alert Policies Module

This Terraform module dynamically provisions and manages Google Cloud Monitoring Alert Policies (e.g., CPU, Filesystem usage) and notification channels, specifically integrating with Moogsoft Webhooks. Configurations are scaled and easily customized by reading from a centralized CSV file.

## Features
- **CSV-driven configuration**: Manage multiple alert policies seamlessly from a single CSV file without writing dense HCL code.
- **Moogsoft Integration**: Automatically sets up the Moogsoft Webhook Notification Channel and routes alerts based on CSV configurations.
- **Dynamic Thresholding & Filtering**: Define custom thresholds, logical comparisons, alert durations, and granular metrics filters per individual alert.

## Usage Structure

```hcl
module "alert_policies" {
  source = "./modules/alert_policies"

  project_id     = var.project_id
  csv_path       = "$${path.module}/alert_policies.csv"
  
  # Moogsoft integration variables
  moogsoft_url   = "https://api.moogsoft.ai/v1/integrations/events" # optional, defaults to this value
  moogsoft_token = var.moogsoft_token
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | The GCP project ID to deploy monitoring resources to. | `string` | n/a | yes |
| `csv_path` | Absolute or relative path to the CSV file defining alerting rules. | `string` | n/a | yes |
| `moogsoft_url` | The URL for the Moogsoft Webhook notification channel endpoint. | `string` | `"https://api.moogsoft.ai/v1/integrations/events"` | no |
| `moogsoft_token` | Sensitive token used to authenticate messages to Moogsoft. | `string` | n/a | yes |

## CSV Configuration

The core of this module is driven by a CSV structure. The CSV must have the following headers:

| Header | Description | Default if empty |
|--------|-------------|-------------------|
| `name` | *(Required)* Display name for the Alert Policy. | n/a |
| `type` | Classification of alert. Generally `CPU` or `FILESYSTEM`. Used to apply default filters. | `""` |
| `threshold` | The percentage utilization (e.g., `85` for 85%). | `80` |
| `duration` | Condition duration threshold (e.g., `300s`). | `"300s"` |
| `comparison` | Condition comparison (e.g., `COMPARISON_GT`). | `"COMPARISON_GT"` |
| `alignment_period` | Size of alignment windows (e.g., `60s`). | `"60s"` |
| `per_series_aligner` | Aligner applied to data series. | `"ALIGN_MEAN"` |
| `notifications` | Comma-separated list of integrations to dispatch alerts to (e.g., `moogsoft`). | `["moogsoft"]` |
| `cross_series_reducer` | Aggregator to reduce cross-series points. | `"REDUCE_MEAN"` |
| `group_by_fields` | Fields to maintain dimensions by, mapped as a list. | `["resource.label.instance_id"]` |
| `filter_custom` | Custom metric filter string. Overrides default CPU/Disk filters. | `""` |

### Example `alert_policies.csv`

```csv
name,type,threshold,duration,comparison,alignment_period,per_series_aligner,notifications,cross_series_reducer,group_by_fields,filter_custom
cpu-usage-high,CPU,85,300s,COMPARISON_GT,60s,ALIGN_MEAN,moogsoft,REDUCE_NONE,"resource.label.instance_id,resource.label.zone",""
disk-usage-high,FILESYSTEM,90,300s,COMPARISON_GT,60s,ALIGN_MEAN,moogsoft,REDUCE_NONE,"resource.label.instance_id,resource.label.zone","metric.type=""agent.googleapis.com/disk/percent_used"" AND resource.type=""gce_instance"" AND metric.labels.state=""used"""
```
