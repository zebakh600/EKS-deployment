variable "domain_name" {
  description = "Root domain bought from Namecheap e.g. yourname.xyz"
  type        = string
  default     = "zeba.click"
}
 
variable "aws_region" {
  description = "AWS region — must be ap-south-1 for ACM to work with ap-south-1 ALBs"
  type        = string
  default     = "ap-south-1"
}
 
variable "project_name" {
  description = "Used as prefix for ECR repo names and resource tags"
  type        = string
  default     = "devops-quiz"
}
 

