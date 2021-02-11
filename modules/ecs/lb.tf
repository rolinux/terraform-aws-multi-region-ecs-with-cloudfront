/* Loadbalancer related resources */
resource "aws_lb" "demo" {
  name               = "demo"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_default_security_group.default.id, aws_security_group.lb_allow_http.id]
  subnets            = data.aws_subnet_ids.default.ids

  tags = {
    Name  = "demo"
    Owner = "Radu"
  }
  depends_on = [aws_security_group.lb_allow_http]
}

resource "aws_lb_target_group" "current" {
  name        = "current"
  port        = var.host_port
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  depends_on  = [aws_lb.demo]
}

resource "aws_lb_target_group" "canary" {
  count       = var.use_canary ? 1 : 0
  name        = "canary"
  port        = var.host_port
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  depends_on  = [aws_lb.demo]
}

resource "aws_lb_listener" "demo" {
  load_balancer_arn = aws_lb.demo.arn
  port              = var.host_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.current.arn
  }

  depends_on = [aws_lb.demo, aws_lb_target_group.current, aws_lb_target_group.canary]
}

resource "aws_lb_listener" "current" {
  count             = var.use_canary ? 0 : 1
  load_balancer_arn = aws_lb.demo.arn
  port              = var.host_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.current.arn
  }

  depends_on = [aws_lb.demo, aws_lb_target_group.current]
}

resource "aws_lb_listener_rule" "host_based_routing" {
  count        = var.use_canary ? 1 : 0
  listener_arn = aws_lb_listener.demo.arn
  priority     = 99

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.current.arn
        weight = 100 - var.canary_percentage
      }

      target_group {
        arn    = aws_lb_target_group.canary[count.index].arn
        weight = var.canary_percentage
      }

      stickiness {
        enabled  = true
        duration = 1
      }
    }
  }

  condition {
    host_header {
      values = ["demo.coroi.net"]
    }
  }

  depends_on = [aws_lb.demo, aws_lb_target_group.current, aws_lb_target_group.canary]
}
