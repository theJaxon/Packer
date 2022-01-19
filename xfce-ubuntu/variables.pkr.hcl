variable "region" {
  type    = string
  default = "af-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "packer_password" {
  type    = string
  description = "default password for packer user"
}