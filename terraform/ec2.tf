data "aws_ami" "jenkins" {
  most_recent = true

  filter {
    name   = "name"
    values = ["jenkins *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}

resource "aws_security_group" "jenkins" {
  name = "jenkins"
  vpc_id = "${aws_vpc.jenkins.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_placement_group" "jenkins-web" {
  name     = "jenkins-web"
  strategy = "spread"
}

resource "aws_launch_configuration" "jenkins-web" {
  name_prefix = "jenkins-web-"
  image_id = "${data.aws_ami.jenkins.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_vpc.jenkins.default_security_group_id}", "${aws_security_group.jenkins.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jenkins" {
  name                      = "jenkins-web"
  max_size                  = "${var.web_instances_max}"
  min_size                  = "${var.web_instances_min}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.web_instances_desired}"
  placement_group           = "${aws_placement_group.jenkins-web.id}"
  launch_configuration      = "${aws_launch_configuration.jenkins-web.name}"
  vpc_zone_identifier       = ["${aws_subnet.jenkins.*.id}"]
  target_group_arns         = ["${aws_lb_target_group.jenkins-http.arn}", "${aws_lb_target_group.jenkins-https.arn}"]

  # force delete to allow asg to be removed before instances are destroyed.
  # Avoids some thrashing of instances being created/destroyed unnecessarily.
  # Instances part of the asg will be destoryed before terraform quits.
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "jenkins-web"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  lifecycle {
    create_before_destroy = true
  }
}
