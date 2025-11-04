########################################
# Provider and Data Sources
########################################
provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

########################################
# Variables
########################################
variable "prefix" {
  type    = string
  default = "shilpa"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "image_tag" {
  description = "Docker image tag for ECS container"
  type        = string
}

########################################
# VPC and Subnets (Reuse Existing)
########################################
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["cohort-11-vpc-vpc"] # Change to match your VPC tag
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"] # Matches any subnet name containing 'public'
  }
}

########################################
# Security Group for ECS
########################################
resource "aws_security_group" "ecs_sg" {
  name        = "${var.prefix}-ecs-sg"
  description = "Allow HTTP traffic for ECS"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################################
# ECR Repository
########################################
resource "aws_ecr_repository" "ecr" {
  name         = "${var.prefix}-ecr"
  force_delete = true
}

########################################
# ECS Cluster and Service
########################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 6.0"

  cluster_name = "${var.prefix}-ecs"

  services = {
    "${var.prefix}-ecs-task-def" = {
      cpu    = 512
      memory = 1024

      container_definitions = {
        "${var.prefix}-container" = {
          essential = true
          image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/${var.prefix}-ecr:${var.image_tag}"
          port_mappings = [
            {
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
        }
      }

      assign_public_ip                   = true
      deployment_minimum_healthy_percent = 100
      subnet_ids                         = data.aws_subnets.public.ids
      security_group_ids                 = [aws_security_group.ecs_sg.id]
    }
  }
}

