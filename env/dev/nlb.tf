# How often to check the liveliness of the container
variable "health_check_interval" {
  default = "30"
}

# The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused
variable "deregistration_delay" {
  default = "30"
}

resource "aws_lb" "main" {
  name                             = "${var.app}-${var.environment}"
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = "true"

  # launch lbs in public or private subnets based on "internal" variable
  internal = "${var.internal}"
  subnets  = "${local.target_subnets}"
  tags     = "${var.tags}"
}

# adds a tcp listener to the load balancer and allows ingress
resource "aws_lb_listener" "tcp" {
  load_balancer_arn = "${aws_lb.main.id}"
  port              = "${var.lb_port}"
  protocol          = "${var.lb_protocol}"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.id}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "main" {
  name                 = "${var.app}-${var.environment}"
  port                 = "${var.lb_port}"
  protocol             = "${var.lb_protocol}"
  vpc_id               = "${var.vpc}"
  target_type          = "ip"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    protocol            = "${var.lb_protocol}"
    interval            = "${var.health_check_interval}"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  tags = "${var.tags}"
}
