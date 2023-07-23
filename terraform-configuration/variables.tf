variable "aws_region" {
  description = "The AWS region to deploy the EC2 instance in."
  default     = "us-east-1"
}


variable "instance_type" {
  description = "instance type for ec2"
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "NodeJS Application server"
}

variable "vpc_name" {
  description = "Name of the vpc"
  type        = string
  default     = "octopus-vpc"
}

variable "ami_id" {
  description = "the AMI id"
  type        = string
  default     = "ami-05bfc1ab11bfbf484"
}

variable "key_name" {
  description = "key name of the ssh key pair in the ec2 creation"
  type        = string
  default     = "ariel"
}

variable "volume_type" {
  description = "The volume type to provision"
  type        = string
  default     = "gp2"
}

variable "volume_size" {
  description = "The size of the volume to provision"
  type        = string
  default     = "8"
}

variable "lb_name" {
  description = "The name of the ALB"
  type        = string
  default     = "octopus-lb"
}

variable "target_group_name" {
  description = "Name of the ALB Target group"
  type        = string
  default     = "octopus-target-group"
}
