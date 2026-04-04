terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" {
    bucket  = "devops-quiz-tfstate-persistent"
    key     = "persistent/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
provider "aws" { region = "ap-south-1" }
 
# ── ECR Repositories ─────────────────────────────────────
locals { services = ["auth-service","quiz-service","user-service","frontend"] }
 
resource "aws_ecr_repository" "services" {
  for_each             = toset(local.services)
  name                 = "devops-quiz/${each.key}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = { Layer = "persistent" }
}
 
# Lifecycle: keep only last 5 images to minimize cost
resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name
  policy = jsonencode({ rules = [{ rulePriority = 1, description = "Keep last 5",
    selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 5 },
    action = { type = "expire" } }] })
}
 
# ── ACM Wildcard Certificate ─────────────────────────────
# *.YOUR_DOMAIN.xyz covers ALL subdomains:
resource "aws_acm_certificate" "main" {
  domain_name               = "*.${var.domain_name}"
  subject_alternative_names = [var.domain_name]
  validation_method         = "DNS"
  lifecycle { create_before_destroy = true }
  tags = { Layer = "persistent", Projects = var.project_name }
}
 
# ── Outputs ──────────────────────────────────────────────
output "ecr_urls" {
  value = { for k,v in aws_ecr_repository.services : k => v.repository_url }
}
output "acm_cert_arn" {
  description = "Reuse this ARN in your ECS Fargate project ALB listener too"
  value = aws_acm_certificate.main.arn
}
output "acm_validation_records" {
  description = "Add these CNAME records in Cloudflare once — covers all subdomains"
  value = { for dvo in aws_acm_certificate.main.domain_validation_options :
    dvo.domain_name => { name = dvo.resource_record_name,
    type = dvo.resource_record_type, value = dvo.resource_record_value } }
}
 
