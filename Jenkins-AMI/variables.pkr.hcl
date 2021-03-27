variable "aws_region" {
  default     = "af-south-1"
  description = "Region where the AMI will be available after the build."
  type        = string
}

variable "ec2_instance" {
  default     = "t3.micro"
  description = "Type of the EC2 instance that will be launched."
  type        = string
}