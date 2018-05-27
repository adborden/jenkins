data "aws_availability_zones" "available" {}

resource "aws_vpc" "jenkins" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "jenkins"
    Env  = "dev"
  }
}

resource "aws_internet_gateway" "jenkins" {
  vpc_id = "${aws_vpc.jenkins.id}"

  tags {
    Name = "jenkins"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = "${aws_vpc.jenkins.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.jenkins.id}"
  }
}

resource "aws_subnet" "jenkins" {
  count = 2
  vpc_id     = "${aws_vpc.jenkins.id}"
  cidr_block = "${cidrsubnet("10.0.0.0/16", 8, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags {
    Name = "jenkins"
  }
}
