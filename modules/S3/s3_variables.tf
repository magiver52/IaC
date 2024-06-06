#####################################################
# Variables Globales
#####################################################
variable "s3_config" {
  type = list(object({
    account     = string
    application = string
    versioning  = string
    }
  ))
}

variable "client" {
  type        = string
  description = "Cliente Bucket"
}

variable "functionality" {
  type        = string
  description = "Funcionalidad Bucket"
}

variable "environment" {
  type        = string
  description = "Ambiente"
}

variable "tags" {
  type = map(string)
}

#####################################################
# Variable de Modulos
#####################################################
