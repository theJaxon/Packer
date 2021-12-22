variable "region" {
  type    = string
  default = "af-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "is_server" {
  type        = bool
  description = "Consul agent mode, the agent can be either in server or client mode, here we default to client mode."
}