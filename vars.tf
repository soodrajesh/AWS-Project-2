variable "my_subnet" {
  type        = list(string)
  default = ["subnet-012345678901", "subnet-012345678902"] 
}

variable "instance_count" {
  type        = number
  default     = 1 
}
