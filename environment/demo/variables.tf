variable "region" {
  type = string
  default = "eu-west-1"
}

variable "project" {
  type = string
  default = "demo-app"
}

variable "container_image" {
  type = string
  default = "chentex/go-rest-api:latest"
}

variable "container_port" {
  type = number
  default = 8080
}

variable "desired_count" {
  type = number
  default = 2
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}
