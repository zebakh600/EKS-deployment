module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
 
  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
 
  cluster_endpoint_public_access = true
  enable_irsa                    = true
 
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
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
  }
}
