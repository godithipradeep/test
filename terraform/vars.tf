variable "vpc_cidr" {
    default = "10.0.0.0/16"
  
}

variable "tenancy" {
    default = "default"
}



variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "mykey"
}