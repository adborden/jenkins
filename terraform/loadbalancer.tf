resource "aws_security_group" "lb" {
  name = "jenkins-lb"
  vpc_id = "${aws_vpc.jenkins.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "jenkins" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_vpc.jenkins.default_security_group_id}", "${aws_security_group.lb.id}"]
  subnets            = ["${aws_subnet.jenkins.*.id}"]

  tags = {
    Name = "jenkins"
    Env  = "dev"
  }
}

resource "aws_lb_target_group" "jenkins-http" {
  name     = "jenkins-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.jenkins.id}"
}

resource "aws_lb_target_group" "jenkins-https" {
  name     = "jenkins-https"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.jenkins.id}"
}

resource "aws_lb_target_group_attachment" "jenkins-http" {
  count = 2
  target_group_arn = "${aws_lb_target_group.jenkins-http.arn}"
  target_id        = "${element(aws_instance.jenkins.*.id, count.index)}"
}

resource "aws_lb_target_group_attachment" "jenkins-https" {
  count = 2
  target_group_arn = "${aws_lb_target_group.jenkins-https.arn}"
  target_id        = "${element(aws_instance.jenkins.*.id, count.index)}"
}

resource "aws_lb_listener" "jenkins-http" {
  load_balancer_arn = "${aws_lb.jenkins.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.jenkins-http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "jenkins-https" {
  load_balancer_arn = "${aws_lb.jenkins.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.jenkins.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.jenkins-https.arn}"
    type             = "forward"
  }
}
