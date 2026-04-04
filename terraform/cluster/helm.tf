# FIX 6: The AWS Load Balancer Controller was installed manually via Helm
# OUTSIDE of Terraform. This is the single biggest reason destroy was painful:
#
#   - The ALB controller created an ALB + ENIs inside your VPC subnets.
#   - Terraform didn't know about the ALB, so it never deleted it before
#     trying to destroy the subnets and IGW.
#   - AWS refused to delete subnets/IGW while ENIs were still attached → the
#     17-minute hang you saw.
#   - The Helm ServiceAccount held an active OIDC trust → IAM role deletion failed.
#
# Fix: manage the Helm release in Terraform. On destroy, Terraform will:
#   1. Delete the Helm release (removes ALB controller + ServiceAccount)
#   2. ALB controller deletes the ALB and its ENIs from AWS
#   3. Terraform then cleanly deletes subnets, IGW, VPC, IAM role
#
# Also fixes the wrong VPC ID bug: vpcId is now sourced directly from
# module.vpc.vpc_id so it is always correct — no more manual Helm installs
# with a hardcoded (wrong) VPC ID.

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.11.0"

  depends_on = [
    module.eks,
    module.alb_irsa,
    null_resource.kubeconfig,
  ]

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.alb_irsa.iam_role_arn
  }
  set {
    name  = "region"
    value = var.aws_region
  }
  # FIX 7: vpcId is sourced from module.vpc so it is always the correct VPC.
  # Previously this was hardcoded in a manual Helm command and was wrong
  # (vpc-061d2bc294d785e12 instead of the actual vpc-056aa7bfd3daea299),
  # which caused the "0 subnets evaluated" error for the entire session.
  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
}
