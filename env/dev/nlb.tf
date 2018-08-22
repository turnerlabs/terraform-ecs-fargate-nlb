resource "aws_lb" "main" {
  name               = "${var.app}-${var.environment}"
  load_balancer_type = "network"

  # launch lbs in public or private subnets based on "internal" variable
  internal = "${var.internal}"
  subnets  = "${split(",", var.internal == true ? var.private_subnets : var.public_subnets)}"
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
