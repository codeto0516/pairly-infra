#################################################
# VPC
#################################################
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true # DNSホスト名を有効化
  enable_dns_support   = true # DNS解決を有効化
  tags = {
    Name = "${var.name}-vpc"
  }
}

#################################################
# VPCエンドポイント
#################################################