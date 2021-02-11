/* Module variables */
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ecs_cluster_name" {
  type    = string
  default = "demo"
}

variable "ecs_capacity_providers" {
  type    = list(string)
  default = ["FARGATE_SPOT"]
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "image_repository" {
  type    = string
  default = "public.ecr.aws/rolinux/demo"
}

variable "image_tag_current" {
  type    = string
  default = "v1"
}

variable "image_tag_canary" {
  type    = string
  default = "v2"
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 3
}

variable "container_port" {
  type    = number
  default = 80
}

variable "host_port" {
  type    = number
  default = 80
}

variable "use_canary" {
  type    = bool
  default = false
}

variable "canary_percentage" {
  type    = number
  default = 0
}
