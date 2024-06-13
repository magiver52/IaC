# ###############################################################
# # Recurso SubnetGroup
# ###############################################################

resource "aws_db_subnet_group" "subgrp_aurora" {
  name       = join("-", tolist(["subgrp", var.functionality, var.environment]))
  subnet_ids = var.subnet_db
}

##################################################################
# Recurso KMS
##################################################################

resource "aws_kms_key" "aws_rds_key" {
  description             = "AWS RDS KMS key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = true
  tags                    = merge({ Name = "${join("-", tolist(["kmsrds", var.functionality, var.environment]))}" })
}

resource "aws_kms_alias" "aws_rds_alias" {
  name          = join("-", tolist(["alias/kmsrds", var.functionality, var.environment]))
  target_key_id = aws_kms_key.aws_rds_key.key_id
}

# resource "random_password" "password" {
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

##################################################################
# RDS Aurora Mysql
##################################################################

resource "aws_rds_cluster" "cluster" {
  #engine                  = "aurora-mysql"
  engine      = "aurora-postgresql"
  engine_mode = "provisioned"
  #engine_version          = "5.7.mysql_aurora.2.11.2"
  engine_version     = "14.8"
  cluster_identifier = join("-", tolist(["rdsclu", var.functionality, var.environment, "auro"]))
  database_name      = var.name_db
  master_username    = var.db_user
  #master_password         = random_password.password.result
  manage_master_user_password = true
  vpc_security_group_ids      = [var.sg_rds]
  storage_encrypted           = true
  kms_key_id                  = aws_kms_key.aws_rds_key.arn
  db_subnet_group_name        = aws_db_subnet_group.subgrp_aurora.name
  backup_retention_period     = 30
  preferred_backup_window     = "12:00-13:00"
  skip_final_snapshot         = true
  tags                        = merge({ Name = "${join("-", tolist(["rdsclu", var.functionality, var.environment, "auro"]))}" })
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier          = join("-", tolist(["rdscluins", var.functionality, var.environment, "auro"]))
  count               = 1
  cluster_identifier  = aws_rds_cluster.cluster.id
  instance_class      = "db.t3.medium"
  engine              = aws_rds_cluster.cluster.engine
  engine_version      = aws_rds_cluster.cluster.engine_version
  publicly_accessible = false
  tags                = merge({ Name = "${join("-", tolist(["rdscluins", var.functionality, var.environment, "auro"]))}" })
}

##################################################################
# Password Administrador RDS
##################################################################

# resource "aws_ssm_parameter" "password_admin_rds" {
#   name  = join("-", tolist(["pws", var.workload, var.environment, "aurora"]))
#   type  = "SecureString"
#   value = aws_rds_cluster.cluster.master_password
# }
