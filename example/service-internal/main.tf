resource "aws_ecs_task_definition" "main" {
    family                   = "${var.name}"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    task_role_arn            = "${var.task_role_arn}"
    execution_role_arn       = "${var.task_role_arn}"
    cpu                      = "256"
    memory                   = "512"
    container_definitions    = <<DEFINITION
[

  {
    "cpu": 128,
    "environment": [
      {
         "name"  : "WAITFOR",
         "value" : "/run/secrets/db"
      }
    ],
    "essential": true,
    "image": "ewilde/wait-tail:latest",
    "memory": ${var.task_memory},
    "name": "${var.name}-wait-tail",
    "volumesFrom": [
        {
          "sourceContainer": "${var.name}"
        }
      ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.wait-tail.name}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "${var.name}-wait-tail"
        }
    },
    "healthCheck": {
        "retries": 1,
        "command": ${var.task_health_check_command},
        "timeout": 3,
        "interval": 5,
        "startPeriod": 5
    }
  },
  {
    "cpu": 128,
    "environment": ${var.task_env_vars},
    "command": ${var.task_command},
    "essential": true,
    "image": "${var.task_image}:${var.task_image_version}",
    "memory": ${var.task_memory},
    "name": "${var.name}",
    "portMappings": ${var.task_ports},
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.main.name}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "${var.name}"
        }
    },
    "healthCheck": {
        "retries": 1,
        "command": ${var.task_health_check_command},
        "timeout": 3,
        "interval": 5,
        "startPeriod": 5
    }
  }
]
DEFINITION
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = "${data.aws_vpc.default.id}"
}

resource "aws_ecs_service" "main" {
    name             = "${var.name}"
    cluster          = "${var.ecs_cluster_name}"
    task_definition  = "${aws_ecs_task_definition.main.arn}"
    launch_type      = "FARGATE"
    desired_count    = "${var.desired_count}"
    network_configuration {
        assign_public_ip = true
        subnets = ["${data.aws_subnet_ids.default.0.ids}"]
    }
}

resource "aws_cloudwatch_log_group" "main" {
    name = "${var.namespace}-${var.name}"
}

resource "aws_cloudwatch_log_group" "wait-tail" {
    name = "${var.namespace}-${var.name}-wait-tail"
}
