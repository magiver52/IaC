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

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = false
}

variable "vpc_config" {
  description = "Configuration for the VPC"
  type = object({
    cidr_block = string
  })
  default = {
    cidr_block = ""
  }
}

variable "existing_vpc_id" {
  description = "The ID of the existing VPC where the subnets will be created"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
    tipo_subnet             = string
  }))
}
