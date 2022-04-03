# 程式碼 git repository, 
resource "aws_codecommit_repository" "my_repository" {
  repository_name = var.my_repository_name
}