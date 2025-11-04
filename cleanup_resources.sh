#!/bin/bash
set -e

echo "Cleaning up AWS resources..."

# Delete ECS Service
aws ecs delete-service --cluster shilpa-ecs --service shilpa-ecs-task-def --force

# Delete ECS Cluster
aws ecs delete-cluster --cluster shilpa-ecs

# Delete ECR Repository
aws ecr delete-repository --repository-name shilpa-ecr --force

# Delete Security Group
aws ec2 delete-security-group --group-id sg-054725d78b04fec94

# Delete CloudWatch Log Group
aws logs delete-log-group --log-group-name /aws/ecs/shilpa-ecs

echo "Cleanup completed."