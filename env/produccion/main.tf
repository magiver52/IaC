##################################
# Modulos Principal
##################################
module "s3" {
  source = "../../modules/S3/"
  client = var.client
  functionality = var.functionality
  environment = var.environment
  s3_config = var.s3_config
}