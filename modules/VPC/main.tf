resource "aws_vpc" "this" {
  count      = var.create_vpc ? 1 : 0
  cidr_block = var.vpc_config.cidr_block
  tags = merge({ Name = "${join("-", tolist(["vpc", var.client, var.environment, var.functionality, "01"]))}" })
}

locals {
  private_subnets = [for subnet in var.subnets : subnet if subnet.tipo_subnet == "private"]
  public_subnets  = [for subnet in var.subnets : subnet if subnet.tipo_subnet == "public"]
}

resource "aws_subnet" "private" {
  count                   = length(local.private_subnets)
  vpc_id                  = var.create_vpc ? aws_vpc.this[0].id : var.existing_vpc_id
  cidr_block              = local.private_subnets[count.index].cidr_block
  availability_zone       = local.private_subnets[count.index].availability_zone
  map_public_ip_on_launch = local.private_subnets[count.index].map_public_ip_on_launch
  tags = merge(
    {
      Name = join("-", [
        "snet",
        var.client,
        var.environment,
        "private",
        format("%02d", count.index + 1)
      ])
    }
  )
}

resource "aws_subnet" "public" {
  count                   = length(local.public_subnets)
  vpc_id                  = var.create_vpc ? aws_vpc.this[0].id : var.existing_vpc_id
  cidr_block              = local.public_subnets[count.index].cidr_block
  availability_zone       = local.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = local.public_subnets[count.index].map_public_ip_on_launch
  tags = merge(
    {
      Name = join("-", [
        "snet",
        var.client,
        var.environment,
        "public",
        format("%02d", count.index + 1)
      ])
    }
  )
}
