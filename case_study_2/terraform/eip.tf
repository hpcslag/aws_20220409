resource "aws_eip" "_" {
  instance = aws_instance._.id
  vpc      = true
}