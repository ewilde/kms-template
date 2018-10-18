variable "name" { description = "name of the service and task" }
variable "ecs_cluster_name" { description = "name of the ecs cluster"}
variable "desired_count" { description = "service desired count"}
variable "task_role_arn" {}
variable "task_cpu" { default = "256" }
variable "task_env_vars" {description = "The raw json of the task env vars" default = "[]"}
variable "task_image" {}
variable "task_image_version" {}
variable "task_memory" { default = "64" }
variable "task_ports" { default = "[]" }
variable "task_health_check_command" { default = "[\"CMD-SHELL\",\"ls\"]" }
variable "task_command" { default = "[]" }
variable "aws_region" {}
variable "namespace" {}
