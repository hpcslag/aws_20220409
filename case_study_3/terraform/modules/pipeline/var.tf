variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "git_branch" {
  type = string
}

variable "deployment_group_name" {
  type = string
}
variable "codedeploy_app_name" {}
variable "deployment_role" {}

variable "additional_build_env_vars" {
  type    = map(any)
  default = {}
}