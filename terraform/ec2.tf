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

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # debugging
  ingress = {
    from_port = 22
    to_port = 22
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

resource "aws_instance" "jenkins" {
  count = 2
  ami           = "${data.aws_ami.jenkins.id}"
  instance_type = "t2.micro"
  subnet_id     = "${element(aws_subnet.jenkins.*.id, count.index)}"
  key_name      = "default"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_vpc.jenkins.default_security_group_id}", "${aws_security_group.jenkins.id}"]

  tags {
    Name = "jenkins"
  }
}

