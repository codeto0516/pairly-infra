#################################################
# アプリケーションロードバランサー
#################################################
resource "aws_lb" "alb" {
  name                       = "terraform-test-alb"
  load_balancer_type         = "application"
  internal                   = false  # 内部ロードバランサーかどうか
  enable_deletion_protection = false  # 削除保護を無効にする場合
  security_groups            = [aws_security_group.alb_sg.id] # セキュリティグループ
  # 配置するサブネット
  subnets                    = [
    aws_subnet.app_public_subnet_1a.id,
    aws_subnet.app_public_subnet_1c.id
  ] 
}

#################################################
# リスナー
#################################################
##### HTTP ##########################
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  # 443ポートにリダイレクト
  default_action {
    type            = "redirect"
    redirect {
      port          = "443"
      protocol      = "HTTPS"
      status_code   = "HTTP_301"
    }
  }

}
##### HTTPS ##########################
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.main.arn

  # 正式はこれ
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  # ALBまでの疎通確認に使うテスト用
  # 使うときにコメントアウトを外す
  # default_action {
  #   type = "fixed-response"

  #   fixed_response {
  #     content_type = "text/plain"
  #     message_body = "これは『HTTP』です"
  #     status_code  = "200"
  #   }
  # }
}
#################################################
# ターゲットグループ
#################################################
resource "aws_lb_target_group" "alb_target_group" {
  name        = "tf-test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.tf_vpc.id

  health_check {
    enabled  = true
    path     = "/"
    port     = "80"
    protocol = "HTTP"
    matcher  = "200-499"
  }
}
