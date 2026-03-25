# ── Additional node security group rules ─────────────────
# The EKS module creates a default node SG automatically.
# These rules extend it for your specific setup.
 
# Allow ALB to reach .NET services on port 8080
resource "aws_security_group_rule" "nodes_from_alb_8080" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = aws_security_group.alb.id
  description              = "ALB  .NET services on 8080"
}
 
# Allow ALB to reach Angular frontend on port 80
resource "aws_security_group_rule" "nodes_from_alb_80" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = aws_security_group.alb.id
  description              = "ALB  nginx frontend on 80"
}
 

 
# ── ALB Security Group ────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.cluster_name}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = module.vpc.vpc_id
 
  # Accept HTTP from anywhere (redirected to HTTPS by ingress annotation)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }
 
  # Accept HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }
 
  # ALB needs to reach nodes — allow all outbound within VPC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "ALB  nodes within VPC"
  }
 
  tags = { Name = "${var.cluster_name}-alb-sg" }
}
 
# Output SG ID so ALB controller can reference it
output "alb_security_group_id" {
  value = aws_security_group.alb.id
}
