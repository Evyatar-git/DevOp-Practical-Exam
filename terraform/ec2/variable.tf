variable "vpc_id" {
  description = "VPC to use"
  type        = string
}

variable "my_ip" {
  description = "Your IP with /32 suffix"
  type        = string
}

variable "public_subnet_id" {
  type = string
}