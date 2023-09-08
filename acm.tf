# 証明書が取得できたらこれを使う
data "aws_acm_certificate" "main" {
  domain = "api.pairly.life"
}




# # ACM SSL/TLS 証明書の作成
# resource "aws_acm_certificate" "certificate" {
#   domain_name       = "codeto.jp"  # 任意のドメイン名を指定してください
#   validation_method = "DNS"

#   tags = {
#     Name = "MyCertificate"
#   }
# }

# # ACM 証明書のバリデーションを待つための待ち時間リソース
# resource "time_sleep" "wait_for_acm_validation" {
#   depends_on = [aws_acm_certificate.certificate]

#   create_duration = "10m"  # 適切な待ち時間を設定してください
# }