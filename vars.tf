variable "my_subnet" {
  type        = list(string)
  default = ["subnet-012345678901", "subnet-012345678902"] 
}

variable "instance_count" {
  type        = number
  default     = 1 
}

variable "region" {
  type        = string
  default = "us-west-2"
}

variable "account_id" {
  type        = number
  default = 01234567890
}

variable "acm_certificate_id" {
  type        = string
  default     = data.aws_acm_certificate.example.arn 
}
