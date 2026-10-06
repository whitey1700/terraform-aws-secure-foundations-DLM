terraform {
  backend "s3" {
    bucket         = "dwight-terraform-state-2026-unique"
    key            = "04-vpc-network/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::<ACCOUNT HOLDER>:role/TerraformDeploymemt Role"
  }
}

# --- Project 04: VPC + Public/Private Subnets (no NAT to avoid cost) ---

resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "tf-vpc-04"
    Project = "04-vpc-network"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "tf-igw-04"
    Project = "04-vpc-network"
  }
}

# Public subnet
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "tf-public-a-04"
    Tier    = "public"
    Project = "04-vpc-network"
  }
}

# Private subnet
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.11.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name    = "tf-private-a-04"
    Tier    = "private"
    Project = "04-vpc-network"
  }
}

# Public route table -> Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "tf-rt-public-04"
    Project = "04-vpc-network"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Private route table (no default route = truly private, no NAT cost)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "tf-rt-private-04"
    Project = "04-vpc-network"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public_a.id
}

output "private_subnet_id" {
  value = aws_subnet.private_a.id
}