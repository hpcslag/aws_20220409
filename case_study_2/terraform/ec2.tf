resource "aws_instance" "_" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = aws_subnet.public.id
  iam_instance_profile   = aws_iam_instance_profile._.name

  tags = {
    Name                = var.namespace
    DeploymentGroupName = var.deployment_group_name
  }

  root_block_device {
    # volume_type = "gp2"
    volume_size = var.volume_size
  }
}