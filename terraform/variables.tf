variable "aws_region" {
  description = "The AWS Region"
  default     = "us-east-1" # <--- CHANGE REGION HERE
}

variable "ami_id" {
  description = "OS ubuntu 22.04 lts"
  default     = "ami-0030e4319cbf4dbf2" # <--- CHANGE OS HERE
}

variable "instance_type" {
  description = "The size of the instance"
  default     = "t3.medium" # <--- CHANGE INSTANCE TYPE HERE
}

variable "key_pair_name" {
  description = "Name for the new SSH Key"
  default     = "Devops-cicd" # <--- CHANGE KEY NAME HERE
}

variable "security_group_name" {
  description = "Name for the Security Group"
  default     = "Devops-cicd" # <--- CHANGE SECURITY GROUP NAME HERE
}

variable "instance_name" {
  description = "The Name tag for the EC2"
  default     = "Devops-cicd" # <--- CHANGE INSTANCE NAME HERE
}