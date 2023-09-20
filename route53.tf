#################################################
# レコードの作成（ALBを登録）
#################################################
resource "aws_route53_record" "alb_record" {
  zone_id = var.route53.zone_id
  name    = var.route53.domain
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

#################################################
# ドメイン検証
#################################################
# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 300
#   type            = each.value.type
#   zone_id         = "Z1009916HGTEXX6X9C3B"
# }

