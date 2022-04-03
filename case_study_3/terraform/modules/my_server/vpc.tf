locals {
  route = [
    {
      cidr_block     = "0.0.0.0/0"
      gateway_id     = aws_internet_gateway._.id
      instance_id    = null
      nat_gateway_id = null
    }
  ]
}

resource "aws_vpc" "_" {
  cidr_block = "${var.vpc_cidr_prefix16}.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.namespace}-vpc"
  }
}

resource "aws_internet_gateway" "_" {
  vpc_id = aws_vpc._.id
}

resource "aws_route_table" "_" {
  vpc_id = aws_vpc._.id

  tags = {
    Name = "${var.namespace}-route-table"
  }
}

resource "aws_route" "_" {
  count                  = length(local.route)
  route_table_id         = aws_route_table._.id
  destination_cidr_block = local.route[count.index].cidr_block
  gateway_id             = local.route[count.index].gateway_id
  network_interface_id   = local.route[count.index].instance_id
  nat_gateway_id         = local.route[count.index].nat_gateway_id
}

resource "aws_main_route_table_association" "_" {
  vpc_id         = aws_vpc._.id
  route_table_id = aws_route_table._.id
}