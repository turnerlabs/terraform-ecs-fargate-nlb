/**
 * This module creates a CloudWatch dashboard for you app,
 * showing its CPU and memory utilization and auto-scaling metrics.
 */

resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "${var.app}-${var.environment}-fargate"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [
            "AWS/ECS",
            "MemoryUtilization",
            "ServiceName",
            "${var.app}-${var.environment}",
            "ClusterName",
            "${var.app}-${var.environment}",
            {
              "color": "#1f77b4"
            }
          ],
          [
            ".",
            "CPUUtilization",
            ".",
            ".",
            ".",
            ".",
            {
              "color": "#9467bd"
            }
          ]
        ],
        "region": "${var.region}",
        "period": 300,
        "title": "Memory and CPU utilization",
        "yAxis": {
          "left": {
            "min": 0,
            "max": 100
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/NetworkELB",
            "UnHealthyHostCount",
            "TargetGroup",
            "${aws_lb_target_group.main.arn_suffix}",
            "LoadBalancer",
            "${aws_lb.main.arn_suffix}",
            {
              "id": "m2",
              "color": "#d62728",
              "stat": "Maximum",
              "period": 1
            }
          ],
          [
            ".",
            "HealthyHostCount",
            ".",
            ".",
            ".",
            ".",
            {
              "period": 1,
              "stat": "Maximum",
              "id": "m3",
              "color": "#98df8a"
            }
          ]
        ],
        "view": "timeSeries",
        "region": "${var.region}",
        "period": 300,
        "stacked": true,
        "title": "Container Count"
      }
    }
  ]
}
EOF
}
