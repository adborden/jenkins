resource "aws_efs_file_system" "jenkins" {
  encrypted = true

  tags {
    Name = "jenkins-efs"
  }
}

resource "aws_efs_mount_target" "jenkins" {
  count = 2
  file_system_id = "${aws_efs_file_system.jenkins.id}"
  subnet_id      = "${element(aws_subnet.jenkins.*.id, count.index)}"
}

