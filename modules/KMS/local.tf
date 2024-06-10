locals {
  required_tags = {
    "environment"  = var.environment
    "cost-center"  = var.cost_center
    "owner"        = var.owner
    "area"         = var.area
    "provisioned"  = "terraform"
  }
  resource_tags = merge(var.tags, local.required_tags)
}