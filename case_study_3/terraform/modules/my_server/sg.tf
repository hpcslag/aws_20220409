resource "aws_security_group" "ec2" {
  name = "${var.namespace}-ec2-sg"
  description = "EC2 security group"
  vpc_id      = aws_vpc._.id
}

resource "aws_security_group_rule" "allow_all_traffics_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.allow_traffic_cidrs
  description       = "all traffic access from local"
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ssh_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allow_traffic_cidrs
  description       = "SSH"
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "http_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP"
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "https_rule" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS"
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "outbound_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "all out traffic"
  security_group_id = aws_security_group.ec2.id
}