variable "iam_config" {
  type = list(object({
    application   = string
    project       = string
    path          = string
    type          = string
    identifiers   = list(string)
    ticket        = string
    policies = list(object({
      policy_description = string
      policy_statements = list(object({
        sid       = string
        actions   = list(string)
        resources = list(string)
        effect    = string
        condition = list(object({
          test     = string
          variable = string
          values   = list(string)
        }))
      }))
    }))
  }))
}

variable "client" {
  type = string
}

variable "environment" {
  type = string
}
