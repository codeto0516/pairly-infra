#################################################
# インターネットゲートウェイ
#################################################
resource "aws_internet_gateway" "tf_internet_gateway" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "igw-${var.name}"
  }
}