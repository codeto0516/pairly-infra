# 証明書が取得できたらこれを使う
data "aws_acm_certificate" "main" {
  domain = var.route53.domain
}