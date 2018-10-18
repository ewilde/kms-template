module "kms_template" {
    source                        = "./service-internal"
    name                          = "kms-template"
    ecs_cluster_name              = "${aws_ecs_cluster.kms-template-example.name}"
    aws_region                    = "${var.aws_region}"
    desired_count                 = "1"
    task_image                    = "ewilde/kms-template"
    task_image_version            = "latest"
    task_role_arn                 = "${aws_iam_role.ecs_role.arn}"
    task_ports                    = "[]"
    task_env_vars                 = <<EOF
[
  {
     "name"  : "SECRETS",
     "value" : "db"
  }

]
EOF
    namespace = "kms-template-test"
}
