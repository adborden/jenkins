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

resource "aws_instance" "jenkins" {
  count = 2
  ami           = "${data.aws_ami.jenkins.id}"
  instance_type = "t2.micro"
  subnet_id     = "${element(aws_subnet.jenkins.*.id, count.index)}"
  vpc_security_group_ids = ["${aws_vpc.jenkins.default_security_group_id}", "${aws_security_group.jenkins.id}"]

  tags {
    Name = "jenkins"
  }
}

