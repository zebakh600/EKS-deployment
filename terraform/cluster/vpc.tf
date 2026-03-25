module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = "${var.cluster_name}-vpc"
  cidr    = "10.0.0.0/16"
 
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  map_public_ip_on_launch = true 

 
  # No NAT gateway — saves ~$32/month for lab
  enable_nat_gateway   = true
  enable_dns_hostnames = false
  enable_dns_support   = true
 

  # Required tags for ALB controller subnet auto-discovery
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
  tags = { Environment = "production" }
}
