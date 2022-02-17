
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "amis" {
  type = string
}

variable "key_name" {
  type    = string
}

variable "associate_public_ip_address"  {
    type  = bool
    default = true
}

variable "vpc_security_group_ids" {
    type  = list 
    default = [""]
}

variable "subnet_id" {
    type  = string
    default = null
}

variable "user_data" {
    type  = string
    default = ""
}

variable "tags" {
    type  = map(string)
    default = {
        Terraform = ""
        Environment = ""
    }
}