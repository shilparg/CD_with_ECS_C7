#!/bin/bash
set -e

echo "Starting Terraform imports..."

# Import Security Group
echo "Importing Security Group..."
terraform import aws_security_group.ecs_sg sg-054725d78b04fec94

# Import ECR Repository
echo "Importing ECR Repository..."
terraform import aws_ecr_repository.ecr shilpa-ecr

# Import CloudWatch Log Group
echo "Importing CloudWatch Log Group..."
terraform import 'module.ecs.module.cluster.aws_cloudwatch_log_group.this[0]' /aws/ecs/shilpa-ecs

# (Optional) Import ECS Cluster
echo "Importing ECS Cluster..."
terraform import 'module.ecs.aws_ecs_cluster.this[0]' shilpa-ecs

# (Optional) Import ECS Service
echo "Importing ECS Service..."
terraform import 'module.ecs.module.service["shilpa-ecs-task-def"].aws_ecs_service.this[0]' shilpa-ecs-task-def

echo "Imports completed. Running terraform plan..."
terraform plan