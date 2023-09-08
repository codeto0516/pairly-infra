#################################################
# ルートテーブル
#################################################
# パブリックサブネット用ルートテーブル
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    "Name" = "${var.name}-public-route-table"
  }
}

# パブリックサブネットにルートテーブルを関連付ける1
resource "aws_route_table_association" "public_subnet_association_1a" {
  subnet_id      = aws_subnet.app_public_subnet_1a.id
  route_table_id = aws_route_table.public_route_table.id
}

# パブリックサブネットにルートテーブルを関連付ける2
resource "aws_route_table_association" "public_subnet_association_1c" {
  subnet_id      = aws_subnet.app_public_subnet_1c.id
  route_table_id = aws_route_table.public_route_table.id
}

# インターネットゲートウェイへのルーティング
resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"  # すべてのトラフィックをインターネットへ
  gateway_id             = aws_internet_gateway.tf_internet_gateway.id
}
