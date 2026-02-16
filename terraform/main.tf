# terraform/main.tf
# Simplified version without Docker provider

# Create ECR repository for storing Docker images
module "ecr" {
  source = "./modules/ecr"
  
  project_name = var.project_name
  environment  = var.environment
}

# Create ECS infrastructure (cluster, service, task definition)
module "ecs" {
  source = "./modules/ecs"
  
  project_name     = var.project_name
  environment      = var.environment
  aws_region       = var.aws_region
  
  # Image will be pushed manually to ECR
  container_image  = "${module.ecr.repository_url}:${var.image_tag}"
  container_port   = var.container_port
  container_cpu    = var.container_cpu
  container_memory = var.container_memory
  
  desired_count    = var.desired_count
  min_capacity     = var.min_capacity
  max_capacity     = var.max_capacity
  
  # Pass ECR repository URL for reference
  ecr_repository_url = module.ecr.repository_url
}

# Output important values
output "ecr_repository_url" {
  description = "ECR repository URL for pushing Docker images"
  value       = module.ecr.repository_url
}

output "load_balancer_url" {
  description = "Load balancer URL to access the application"
  value       = module.ecs.load_balancer_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}