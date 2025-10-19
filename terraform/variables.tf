variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name for EC2"
  type        = string
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 80
}
