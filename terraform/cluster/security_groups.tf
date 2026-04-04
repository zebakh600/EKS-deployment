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
  description              = "ALB to .NET services on 8080"
}

# Allow ALB to reach Angular frontend on port 80
resource "aws_security_group_rule" "nodes_from_alb_80" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = aws_security_group.alb.id
  description              = "ALB to nginx frontend on 80"
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

  # FIX 9: egress was restricted to vpc_cidr_block only.
  # The ALB controller needs outbound HTTPS (443) to call AWS APIs
  # (ELB, EC2, ACM). Restricting to VPC CIDR blocks those calls silently,
  # causing the controller to hang. Allow all outbound — standard for ALBs.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }

  # FIX 10: Added lifecycle rule so Terraform replaces the SG cleanly on
  # destroy/recreate instead of failing due to dependent ENIs still attached.
  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "${var.cluster_name}-alb-sg" }
}
