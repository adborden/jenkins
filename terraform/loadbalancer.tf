resource "aws_lb" "jenkins" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.jenkins.*.id}"]

  tags = {
    Name = "jenkins"
    Env  = "dev"
  }
}

resource "aws_lb_target_group" "jenkins" {
  name     = "jenkins-web"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.jenkins.id}"
}

resource "aws_lb_target_group_attachment" "jenkins" {
  count = 2
  target_group_arn = "${aws_lb_target_group.jenkins.arn}"
  target_id        = "${element(aws_instance.jenkins.*.id, count.index)}"
}

resource "aws_lb_listener" "jenkins-http" {
  load_balancer_arn = "${aws_lb.jenkins.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.jenkins.arn}"
    type             = "forward"
  }
}
