#Output PEM Ec2 - Module EC2
output "rds_lab_aurora" {
  value = aws_rds_cluster.cluster.endpoint
}
