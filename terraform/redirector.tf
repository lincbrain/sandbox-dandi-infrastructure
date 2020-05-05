resource "aws_route53_record" "redirector" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "" # apex
  type    = "A"
  ttl     = "300"
  records = ["3.12.21.28"]
}
