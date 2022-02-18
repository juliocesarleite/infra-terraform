variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "amis" {
  type = string
  default = "ami-07b5a89195c6932c8"
}

variable "key_name" {
  type    = string
  default = "julio-key2"
}