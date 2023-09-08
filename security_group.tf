#################################################
# ロードバランサー用セキュリティグループ
#################################################
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "ALB Secuirty Group"
  vpc_id      = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf-alb-sg"
  }
}

# インバウンドルール（HTTP）
resource "aws_security_group_rule" "alb_allow_http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# インバウンドルール（HTTPS）
resource "aws_security_group_rule" "alb_allow_https_inbound" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}


# アウトバウンドルール
resource "aws_security_group_rule" "alb_allow_app_sg_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb_sg.id
  source_security_group_id = aws_security_group.app_sg.id
}


#################################################
# アプリケーション用セキュリティグループ
#################################################
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Application Secuirty Group"
  vpc_id      = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf-app-sg"
  }
}

# インバウンドルール
resource "aws_security_group_rule" "app_allow_http_inbound" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

# インバウンドルール
resource "aws_security_group_rule" "app_allow_https_inbound" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

# アウトバウンドルール
resource "aws_security_group_rule" "allow_every_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.app_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}


