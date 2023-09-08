# CIDR
locals {
  public_1a  = "10.0.0.0/20"
  public_1c  = "10.0.16.0/20"
  private_1a = "10.0.128.0/20"
  private_1c = "10.0.144.0/20"
}

#################################################
# パブリックサブネット
#################################################
resource "aws_subnet" "app_public_subnet_1a" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = local.public_1a
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.name}-app-public-subnet-1a"
  }
}

resource "aws_subnet" "app_public_subnet_1c" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = local.public_1c
  availability_zone = "${var.region}c"
  tags = {
    Name = "${var.name}-app-public-subnet-1c"
  }
}

#################################################
# プライベートサブネット
#################################################
resource "aws_subnet" "app_private_subnet_1a" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = local.private_1a
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.name}-app-private-subnet-1a"
  }
}

resource "aws_subnet" "app_private_subnet_1c" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = local.private_1c
  availability_zone = "${var.region}c"
  tags = {
    Name = "${var.name}-app-private-subnet-1c"
  }
}
