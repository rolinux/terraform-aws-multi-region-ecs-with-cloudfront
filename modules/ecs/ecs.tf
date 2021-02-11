/* ECS resources */
resource "aws_ecs_cluster" "demo" {
  name               = var.ecs_cluster_name
  capacity_providers = var.ecs_capacity_providers

  tags = {
    Name  = "My ECS Demo cluster"
    Owner = "Radu"
  }
}

resource "aws_ecs_task_definition" "current" {
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "current",
    "image": "${var.image_repository}:${var.image_tag_current}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.host_port}
      }
    ]
  }
]
TASK_DEFINITION

  tags = {
    Name  = "My ECS Demo current task"
    Owner = "Radu"
  }
}

resource "aws_ecs_task_definition" "canary" {
  count                    = var.use_canary ? 1 : 0
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "canary",
    "image": "${var.image_repository}:${var.image_tag_canary}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.host_port}
      }
    ]
  }
]
TASK_DEFINITION

  tags = {
    Name  = "My ECS Demo canary task"
    Owner = "Radu"
  }
}

resource "aws_ecs_service" "current" {
  name            = "current"
  cluster         = aws_ecs_cluster.demo.id
  task_definition = aws_ecs_task_definition.current.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.current.arn
    container_name   = "current"
    container_port   = var.host_port
  }

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    assign_public_ip = var.assign_public_ip
    subnets          = data.aws_subnet_ids.default.ids
  }
}

resource "aws_ecs_service" "canary" {
  count           = var.use_canary ? 1 : 0
  name            = "canary"
  cluster         = aws_ecs_cluster.demo.id
  task_definition = aws_ecs_task_definition.canary[count.index].arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.canary[count.index].arn
    container_name   = "canary"
    container_port   = var.host_port
  }

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    assign_public_ip = var.assign_public_ip
    subnets          = data.aws_subnet_ids.default.ids
  }
}
