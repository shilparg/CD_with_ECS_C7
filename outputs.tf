# Outputs for GitHub Actions
output "ecr_repository" {
  value = aws_ecr_repository.ecr.name
}

output "ecs_cluster" {
  value = module.ecs.cluster_name
}

output "ecs_service" {
  value = "${var.prefix}-ecs-task-def"
}

output "container_name" {
  value = "${var.prefix}-container"
}

output "task_definition" {
  value = "${var.prefix}-ecs-task-def"
}