resource "aws_batch_compute_environment" "nextflow" {

  compute_environment_name = "nextflow"

  compute_resources {
    instance_role = aws_iam_instance_profile.ecs_instance.arn

    allocation_strategy = "BEST_FIT"

    instance_type = ["optimal"]

    ec2_configuration {
      image_id_override = var.ami_id
      image_type = "ECS_AL2"
    }

    max_vcpus     = 64
    min_vcpus     = 0

    security_group_ids = [
      aws_security_group.batch.id
    ]

    subnets = [
      aws_subnet.private.id
    ]

    type = "EC2"

  }

  service_role = aws_iam_role.aws_batch_service.arn
  type         = "MANAGED"
  state        = "ENABLED"

  # For preventing race condition during deletion. See:
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment
  depends_on = [aws_iam_role_policy_attachment.batch_service]
}


resource "aws_batch_job_queue" "default" {
  name     = "nextflow_queue"
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.nextflow.arn,
  ]
}
