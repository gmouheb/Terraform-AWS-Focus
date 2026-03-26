variable "namespace" {
  description = "The project namespace"
  type = string
}

variable "ssh_keypair" {
  description = "SSH Keypair to use for EC2 Instance"
  default = null  //Null is useful for optional variables that don’t have a meaningful default value
  type = string
}

variable "region" {
  description = "AWS Region"
  default = "us-west-2"
  type = string
}

