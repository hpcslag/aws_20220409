resource "aws_iam_instance_profile" "_" {
  name = "${var.namespace}-ec2-instance-profile"
  role = aws_iam_role._.name
}

resource "aws_iam_role" "_" {
  name = "${var.namespace}-ec2-instance-role"

  assume_role_policy = templatefile("./policies/ec2_assume_policy.tpl", {})
}

resource "aws_iam_role_policy" "ec2" {
  name = "${var.namespace}-ec2-policy"
  role = aws_iam_role._.id

  policy = templatefile("./policies/ec2_role_policy.tpl", {})
}
