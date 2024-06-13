################################################################################
# Variable Globales - Comunes
################################################################################

variable "functionality" {}
variable "environment" {}
variable "aws_region" {}
variable "subnet_db" {}
variable "vpcidout" {}
variable "sg_rds" {}

################################################################################
# Variable RDS
################################################################################

variable "name_db" {
  default = "world"
}

variable "db_user" {
  description = "Usuario para la conexion a la DB"
  default     = "mastersoyyo"
}



