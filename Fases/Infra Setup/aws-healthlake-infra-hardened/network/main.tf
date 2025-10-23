terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "vpc_cidr" { type = string }
variable "az_count" { type = number  default = 2 }
variable "name_prefix" { type = string }
variable "private_subnet_bits" { type = number default = 24 }

provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name    = "${var.name_prefix}-vpc"
    Project = "AWS-HealthLake"
  }
}

resource "aws_subnet" "private" {
  for_each = { for idx, az in local.azs : idx => az }
  vpc_id            = aws_vpc.this.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.key + 1) # /24 from /16
  tags = {
    Name = "${var.name_prefix}-private-${each.value}"
    Tier = "private"
  }
}

# VPC Endpoints (Interface/Gateway where applicable)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.private : rt.id]
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  tags = { Name = "${var.name_prefix}-rt-${each.key}" }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = each.value.id
}

# Common interface endpoints

resource "aws_security_group" "vpce_sg" {
  name   = "${var.name_prefix}-vpce-sg"
  vpc_id = aws_vpc.this.id
  description = "Restrict VPC Interface Endpoints to VPC CIDR on 443"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-vpce-sg" }
}

locals {
  interface_services = [
    "com.amazonaws.${var.region}.logs",
    "com.amazonaws.${var.region}.monitoring",
    "com.amazonaws.${var.region}.sts",
    "com.amazonaws.${var.region}.kms"
  ]
}

resource "aws_vpc_endpoint" "interfaces" {
  for_each          = toset(local.interface_services)
  vpc_id            = aws_vpc.this.id
  service_name      = each.key
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = [for s in aws_subnet.private : s.id]
  security_group_ids = [aws_security_group.vpce_sg.id]
  tags = { Name = "${var.name_prefix}-endpoint-${replace(each.key, "com.amazonaws.${var.region}.", "")}" }
}

output "vpc_id" { value = aws_vpc.this.id }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }