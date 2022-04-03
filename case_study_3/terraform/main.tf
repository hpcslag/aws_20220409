locals {
    codedeploy_app_name = "${var.namespace}-codedeploy"
    deployment_group_name = "${var.namespace}_deploygroup"
    codepipeline_name = "${var.namespace}-codepipeline"
}

# 程式碼 git repository
resource "aws_codecommit_repository" "my_repository" {
  repository_name = var.repository_name
}

// 建立一個 code deploy application
resource "aws_codedeploy_app" "my_codedeploy" {
  compute_platform = "Server"
  name             = local.codedeploy_app_name
}

# 建立一個 deployment group
module "my_deployment_group" {
  source = "./modules/deployment_group"

  # 用上定義的名稱
  deployment_group_name = local.deployment_group_name
  app_name              = aws_codedeploy_app.my_codedeploy.name
}

########################################

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.deployer_key
}

module "my_server" {
  source = "./modules/my_server"
  aws_region = var.aws_region
  namespace = var.namespace
  instance_type = var.instance_type

  # change
  deployment_group_name = local.deployment_group_name

  volume_size = var.volume_size
  ec2_ami = var.ec2_ami
  allow_traffic_cidrs = var.allow_traffic_cidrs
  availability_zone_1 = var.availability_zone_1
  availability_zone_2 = var.availability_zone_2
  key_name = var.key_name
  vpc_cidr_prefix16 = var.vpc_cidr_prefix16
}

module "my_pipeline" {
  source       = "./modules/pipeline"

  name         = local.codepipeline_name
  aws_region   = var.aws_region

  

  project_name    = "${var.namespace}-pipeline"
  repository_name = var.repository_name
  git_branch      = "staging"

  env          = "build"
 

  # 使用剛才那個模組建立的 deployment group 
  deployment_role       = module.my_deployment_group.deployment_role
  # 使用最上面的那個 deployment group name
  deployment_group_name = local.deployment_group_name
  # 使用剛才定義的 codedeploy app name
  codedeploy_app_name   = aws_codedeploy_app.my_codedeploy.name
}