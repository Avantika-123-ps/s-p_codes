resource "google_monitoring_dashboard" "my_top_vms_dashboard" {
  project      = var.project_id
  display_name = "Top 10 VM Resource Usage (Linux & Windows)"

  # The dashboard definition in JSON format.
  dashboard_json = jsonencode({
    "displayName" : "Top 10 VM Resource Usage (Linux & Windows)",
    "mosaicLayout" : {
      "columns" : 12,
      "tiles" : [
        # --- TOP 10 CPU Utilization ---
        {
          "xPos" : 0, "yPos" : 0, "width" : 6, "height" : 4,
          "widget" : {
            "title" : "Top 10 Linux VMs by CPU Utilization (%)",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "mqlQuery" : join("\n", [
                      "fetch gce_instance",
                      "| metric 'compute.googleapis.com/instance/cpu/utilization'",
                      "# Uncomment and adjust the filter below if instances have 'os:linux' labels:",
                      "# | filter (metadata.user_labels.os == 'linux')",
                      "| group_by 1m, [value_mean: mean(value.utilization)]",
                      "| every 1m",
                      "| group_by [resource.instance_id, resource.project_id], [value_mean_mean: mean(value_mean)]",
                      "| top 10"
                    ])
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : { "label" : "CPU Utilization (%)", "scale" : "LINEAR" }
            }
          }
        },
        {
          "xPos" : 6, "yPos" : 0, "width" : 6, "height" : 4,
          "widget" : {
            "title" : "Top 10 Windows VMs by CPU Utilization (%)",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "mqlQuery" : join("\n", [
                      "fetch gce_instance",
                      "| metric 'compute.googleapis.com/instance/cpu/utilization'",
                      "# Uncomment and adjust the filter below if instances have 'os:windows' labels:",
                      "# | filter (metadata.user_labels.os == 'windows')",
                      "| group_by 1m, [value_mean: mean(value.utilization)]",
                      "| every 1m",
                      "| group_by [resource.instance_id, resource.project_id], [value_mean_mean: mean(value_mean)]",
                      "| top 10"
                    ])
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : { "label" : "CPU Utilization (%)", "scale" : "LINEAR" }
            }
          }
        },
        # --- TOP 10 Memory Utilization (Requires Ops Agent) ---
        {
          "xPos" : 0, "yPos" : 4, "width" : 6, "height" : 4,
          "widget" : {
            "title" : "Top 10 Linux VMs by Memory Utilization (%)",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "mqlQuery" : join("\n", [
                      "fetch gce_instance",
                      "| metric 'agent.googleapis.com/memory/percent_used'",
                      "| filter (metric.state == 'used')",
                      "# Uncomment and adjust the filter below if instances have 'os:linux' labels:",
                      "# | filter (metadata.user_labels.os == 'linux')",
                      "| group_by 1m, [value_mean: mean(value.percent_used)]",
                      "| every 1m",
                      "| group_by [resource.instance_id, resource.project_id], [value_mean_mean: mean(value_mean)]",
                      "| top 10"
                    ])
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : { "label" : "Memory Utilization (%)", "scale" : "LINEAR" }
            }
          }
        },
        {
          "xPos" : 6, "yPos" : 4, "width" : 6, "height" : 4,
          "widget" : {
            "title" : "Top 10 Windows VMs by Memory Utilization (%)",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "mqlQuery" : join("\n", [
                      "fetch gce_instance",
                      "| metric 'agent.googleapis.com/memory/percent_used'",
                      "| filter (metric.state == 'used')",
                      "# Uncomment and adjust the filter below if instances have 'os:windows' labels:",
                      "# | filter (metadata.user_labels.os == 'windows')",
                      "| group_by 1m, [value_mean: mean(value.percent_used)]",
                      "| every 1m",
                      "| group_by [resource.instance_id, resource.project_id], [value_mean_mean: mean(value_mean)]",
                      "| top 10"
                    ])
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : { "label" : "Memory Utilization (%)", "scale" : "LINEAR" }
            }
          }
        },
        # --- TOP 10 Filesystem Utilization (Requires Ops Agent) ---
        {
          "xPos" : 0, "yPos" : 8, "width" : 6, "height" : 4,
          "widget" : {
            "title" : "Top 10 Linux VMs by Filesystem Usage (%)",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "mqlQuery" : join("\n", [
                      "fetch gce_instance",
                      "| metric 'agent.googleapis.com/disk/percent_used'",
                      "| filter (metric.state == 'used')",
                      "# Uncomment and adjust the filter below if instances have 'os:linux' labels:",
                      "# | filter (metadata.user_labels.os == 'linux')",
                      "| group_by 1m, [value_mean: mean(value.percent_used)]",
                      "| every 1m",
                      "| group_by [resource.instance_id, metric.device, resource.project_id], [value_mean_mean: mean(value_mean)]",
                      "| top 10"
                    ])
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : { "label" : "Filesystem Usage (%)", "scale" : "LINEAR" }
            }
          }
        },
        {
          "xPos" : 6, "yPos" : 8, "width" : 6, "height" : 4,
          "widget" : {
            "title" : "Top 10 Windows VMs by Filesystem Usage (%)",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "mqlQuery" : join("\n", [
                      "fetch gce_instance",
                      "| metric 'agent.googleapis.com/disk/percent_used'",
                      "| filter (metric.state == 'used')",
                      "# Uncomment and adjust the filter below if instances have 'os:windows' labels:",
                      "# | filter (metadata.user_labels.os == 'windows')",
                      "| group_by 1m, [value_mean: mean(value.percent_used)]",
                      "| every 1m",
                      "| group_by [resource.instance_id, metric.device, resource.project_id], [value_mean_mean: mean(value_mean)]",
                      "| top 10"
                    ])
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : { "label" : "Filesystem Usage (%)", "scale" : "LINEAR" }
            }
          }
        }
      ]
    }
  })
}

