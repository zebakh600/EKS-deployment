variable "aws_region"          { default = "ap-south-1" }
variable "cluster_name"        { default = "devops-quiz-eks" }
variable "domain_name"         { default = "zeba.click" }
variable "subdomain"           { default = "eks" }
variable "node_instance_type"  { default = "t3.small" }
variable "node_desired_count"  { default = 2 }
variable "node_min_count"      { default = 1 }
variable "node_max_count"      { default = 3 }
