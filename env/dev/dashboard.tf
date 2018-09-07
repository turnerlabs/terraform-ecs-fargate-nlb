/**
 * This module creates a CloudWatch dashboard for you app,
 * showing its CPU and memory utilization and various HTTP-related metrics.
 *
 * The graphs of HTTP requests are stacked.  Green indicates successful hits
 * (HTTP response codes 2xx), yellow is used for client errors (HTTP response
 * codes 4xx) and red is used for server errors (HTTP response codes 5xx).
 * Stacking is used because, when things are running smoothly, those graphs
 * will be predominately green, making the dashboard easier to check
 * at a glance or at a distance.
 *
 * One of the graphs shows HTTP response codes returned by your containers.
 * Another graph shows HTTP response codes returned by your load balancer.
 * Although these two graphs often look very similar, there are situations
 * where they will differ.
 * If your containers are responding 200 OK but are taking too long to
 * respond, the load balancer will return 504 Gateway Timeout.  In that
 * case, the containers' graph could show green while the load balancer's
 * graph shows red.
 * If many of your containers are failing their healthchecks, the load
 * balancer will direct traffic to the healthy containers.  In that case,
 * the load balancer's graph could show green while the containers'
 * graph shows red.
 * The containers' graph might show more traffic than the load balancer's.
 * Some of the containers' traffic is due to the healthchecks, which
 * originate with the load balancer.  Also, it is possible that future
 * load balancers will re-attempt HTTP requests that the HTTP standard
 * declares idempotent.
 *
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
                    [ "AWS/ECS", "MemoryUtilization", "ServiceName", "fargate-nlb-test5-dev", "ClusterName", "fargate-nlb-test5-dev", { "color": "#1f77b4" } ],
                    [ ".", "CPUUtilization", ".", ".", ".", ".", { "color": "#9467bd" } ]
                ],
                "region": "us-east-1",
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
                    [ "AWS/NetworkELB", "HealthyHostCount", "TargetGroup", "targetgroup/fargate-nlb-test5-dev/a10d6304997f5239", "LoadBalancer", "net/fargate-nlb-test5-dev/cb1847fcb7917d9b" ],
                    [ ".", "UnHealthyHostCount", ".", ".", ".", "." ]
                ],
                "view": "timeSeries",
                "region": "us-east-1",
                "period": 300,
                "stacked": false
            }
        }
    ]
}
EOF
}
