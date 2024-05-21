##################################
# Variables del Ambiente Dev
##################################

#
# Variable Region AWS
#
variable "aws_region" {
  default     = ""
  description = "Variable Region AWS"
}

#
# Variable Profile 
#
variable "profile" {
  default     = ""
  description = "Profile AWS - Lab"
}

#
# Variables Local Tags
#
locals {
  tags = {
    workload = "Lab Terraform"
    env      = "Dev"
    owner    = "Felipe Arciniegas"
  }

  tags2 = {
    workload    = "Lab Terraform"
    env         = "Dev"
    owner       = "Fredy Patino"
    presupuesto = "500"
  }
}

#
# variables S3
#
variable "bucket-s3" {
  default     = ["linux01", "linux02", "linux03"]
  description = "Listado Bucket S3"
}

variable "environment" {
  default = ""
}

##################################
# Variables del Module S3
##################################
variable "client" {
  default = ""
  description = "Cliente de la solucion"
}

variable "functionality" {
  default = ""
  description = "Funcionabilidad"
}

variable "s3_config" {
  default = ""
  description = "Definiciones S3"
}