variable "region" {
  default = "eu-north-1"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  default = "plats-key"
  type        = string
}

variable "db_name" {
  default = "platsbokning_production"
}

variable "db_username" {
  default = "platsbokning"
}

variable "db_password" {
  default = "g7Hk3qZ9R4"
}
