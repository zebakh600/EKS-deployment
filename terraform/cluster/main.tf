terraform {
  required_version = ">= 1.7"
  required_providers {
    aws        = { source = "hashicorp/aws",        version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.0" }
    http       = { source = "hashicorp/http",       version = "~> 3.0" }
  }
  backend "s3" {
    bucket  = "devops-quiz-tfstate-cluster"
    key     = "cluster/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
provider "aws" { region = var.aws_region }
 
# Read ACM cert ARN from persistent layer
data "terraform_remote_state" "persistent" {
  backend = "s3"
  config  = { bucket = "devops-quiz-tfstate-persistent",
              key = "persistent/terraform.tfstate", region = "ap-south-1" }
}
 
locals {
  acm_cert_arn = data.terraform_remote_state.persistent.outputs.acm_cert_arn
}
 
data "aws_caller_identity"   "current"   {}
data "aws_availability_zones" "available" {}
