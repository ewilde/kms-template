resource "aws_ecs_cluster" "kms-template-example" {
    name = "kms-template-example"
}

resource "aws_iam_role" "ecs_role" {
    assume_role_policy = "${file("${path.module}/data/iam/ecs-task-assumerole.json")}"
}

data "aws_secretsmanager_secret" "db" {
    name = "db"
}

resource "aws_iam_role_policy" "ecs_role_policy" {
    name   = "kms-template-example-task-role"
    role = "${aws_iam_role.ecs_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    ${file("${path.module}/data/iam/log-policy.json")},
    {
        "Effect": "Allow",
        "Action": [
            "secretsmanager:GetSecretValue"
        ],
        "Resource": "${data.aws_secretsmanager_secret.db.id}"
    }
  ]
}
EOF
}
