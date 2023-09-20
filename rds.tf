#################################################
# RDS
#################################################
resource "aws_db_instance" "rds" {
    # エンジン
    engine                 = "mysql"
    engine_version         = "8.0.33"

    # DB
    identifier             = "pairly-backend-rds"
    db_name                = var.rds.db_name
    username               = var.rds.username
    password               = var.rds.password

    # インスタンス
    instance_class         = "db.t3.micro"

    # ストレージ
    storage_type           = "gp2"
    allocated_storage      = 20

    # 接続
    vpc_security_group_ids = [aws_security_group.rds_sg.id]
    db_subnet_group_name   = aws_db_subnet_group.rds.name
    
    # スナップショット
    skip_final_snapshot    = true
}

#################################################
# サブネットグループ
#################################################
resource "aws_db_subnet_group" "rds" {
  name        = "pairly-backend-rds-subnet-group"
  description = "rds subnet group for tf"
  subnet_ids  = [aws_subnet.app_private_subnet_1a.id, aws_subnet.app_private_subnet_1c.id]
}

#################################################
# セキュリティグループ
#################################################
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "RDS Secuirty Group"
  vpc_id      = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf-rds-sg"
  }
}

# インバウンドルール
resource "aws_security_group_rule" "rds_allow_inbound" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.app_sg.id
}

# アウトバウンドルール
resource "aws_security_group_rule" "rds_allow_every_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

