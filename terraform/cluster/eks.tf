module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets

  cluster_endpoint_public_access = true
  enable_irsa                    = true

  # FIX B: enable_cluster_creator_admin_permissions = true automatically creates
  # an access entry for the IAM identity that ran terraform apply (zeba-1).
  # The previous access_entries block for zeba-admin was ALSO creating an entry
  # for zeba-1, causing "ResourceInUseException: access entry already in use"
  # on every rebuild because the access entry from the first apply was still
  # present in AWS when the second apply tried to create it again.
  # Solution: remove access_entries entirely — this flag covers zeba-1 automatically.
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    spot = {
      name           = "spot-nodes"
      instance_types = ["t3.small", "t3.medium"]
      capacity_type  = "SPOT"
      min_size       = var.node_min_count
      max_size       = var.node_max_count
      desired_size   = var.node_desired_count
      labels         = { role = "worker" }
    }
  }

  tags = { Environment = "production" }
}

resource "null_resource" "kubeconfig" {
  depends_on = [module.eks]

  triggers = {
    cluster_name = var.cluster_name
    region       = var.aws_region
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl config delete-context arn:aws:eks:${self.triggers.region}:$(aws sts get-caller-identity --query Account --output text):cluster/${self.triggers.cluster_name} 2>/dev/null || true"
  }
}
