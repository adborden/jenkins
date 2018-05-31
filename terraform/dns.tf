data "aws_route53_zone" "aws" {
  name         = "aws.adborden.net."
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.aws.zone_id}"
  name    = "${var.domain_prefix}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.jenkins.dns_name}"]
}

resource "aws_acm_certificate" "jenkins" {
  domain_name = "jenkins.aws.adborden.net"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name = "${aws_acm_certificate.jenkins.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.jenkins.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.aws.id}"
  records = ["${aws_acm_certificate.jenkins.domain_validation_options.0.resource_record_value}"]
  ttl = 600
}

resource "aws_acm_certificate_validation" "jenkins" {
  certificate_arn = "${aws_acm_certificate.jenkins.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
