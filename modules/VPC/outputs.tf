output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.create_vpc ? aws_vpc.this[0].id : var.existing_vpc_id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_availability_zones" {
  description = "The availability zones of the private subnets"
  value       = aws_subnet.private[*].availability_zone
}

output "public_availability_zones" {
  description = "The availability zones of the public subnets"
  value       = aws_subnet.public[*].availability_zone
}
