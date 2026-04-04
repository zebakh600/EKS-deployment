terraform {
  required_version = ">= 1.7"
  required_providers {
    aws        = { source = "hashicorp/aws",        version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
    helm       = { source = "hashicorp/helm",       version = "2.12.1" }
    http       = { source = "hashicorp/http",       version = "~> 3.0" }
    cloudinit  = { source = "hashicorp/cloudinit",  version = "~> 2.3" }
    null       = { source = "hashicorp/null",       version = "~> 3.0" }
    # FIX: tls provider is used internally by the EKS module to compute the
    # OIDC thumbprint. Without it declared here, Terraform cannot load the
    # plugin during destroy and fails with "requires explicit configuration".
    tls        = { source = "hashicorp/tls",        version = "~> 4.0" }
  }
  backend "s3" {
    bucket  = "devops-quiz-tfstate-cluster"
    key     = "cluster/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

provider "aws" { region = var.aws_region }

# The helm and kubernetes providers need to connect to the cluster.
# During destroy the cluster still exists so these work fine.
# The try() guards against the edge case where state is empty.
locals {
  cluster_endpoint = try(module.eks.cluster_endpoint, "")
  cluster_ca       = try(module.eks.cluster_certificate_authority_data, "")
  kubeconfig_ready = local.cluster_endpoint != ""
}

provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = local.kubeconfig_ready ? base64decode(local.cluster_ca) : ""
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.aws_region]
  }
}

# FIX: Pinned to 2.12.1 — the 2.13+ builds have a plugin crash on WSL2
# (Linux provider binary linked against glibc version not present in WSL).
# 2.12.1 is the last version that works cleanly on WSL2 Ubuntu.
provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.kubeconfig_ready ? base64decode(local.cluster_ca) : ""
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.aws_region]
    }
  }
}

# Read ACM cert ARN from persistent layer
data "terraform_remote_state" "persistent" {
  backend = "s3"
  config  = {
    bucket = "devops-quiz-tfstate-persistent"
    key    = "persistent/terraform.tfstate"
    region = "ap-south-1"
  }
}

locals {
  acm_cert_arn = data.terraform_remote_state.persistent.outputs.acm_cert_arn
}

data "aws_caller_identity"    "current"   {}
data "aws_availability_zones" "available" {}
