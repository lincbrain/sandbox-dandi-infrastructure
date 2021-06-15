resource "aws_route53_zone" "dandi" {
  name = "dandiarchive.org"
}

resource "aws_route53_record" "acm_validation" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "_cbe41dfe1888c2bb5c157cacc35e1722"
  type    = "CNAME"
  ttl     = "300"
  records = ["_46df7ee9a9c17698aedbb737f220c63a.mzlfeqexyx.acm-validations.aws"]
}

resource "aws_route53_record" "gui" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "gui"
  type    = "CNAME"
  ttl     = "300"
  records = ["gui-dandiarchive-org.netlify.com"]
}

resource "aws_route53_record" "gui-staging" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "gui-staging"
  type    = "CNAME"
  ttl     = "300"
  records = ["gui-staging-dandiarchive-org.netlify.com"]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "300"
  records = ["dandi.github.io"]
}

resource "aws_route53_record" "email" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "" # apex
  type    = "MX"
  ttl     = "300"
  records = [
    "10 mx1.improvmx.com.",
    "20 mx2.improvmx.com.",
  ]
}
