variable "s3_config" {
  type = list(object({
    ticket      = string
    application = string
    kms_key_id = string
    accessclass = string
    versioning = string
    statements = list(object({
      sid         = string
      actions     = list(string)
      effect      = string
      type        = string
      identifiers = list(string)
      condition = list(object({
        test     = string
        variable = string
        values   = list(string)
      }))
    }))
  }))
}

variable "functionality" {
  type = string
}

variable "client" {
  type = string
}

variable "environment" {
  type = string
}