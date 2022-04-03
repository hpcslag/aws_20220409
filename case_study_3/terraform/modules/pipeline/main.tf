locals {
  pipeline_name          = "${var.project_name}-pipeline"
  codebuild_project_name = "${var.project_name}-codebuild"
  artifact_bucket_name   = "${var.project_name}-artifacts"
}

# Pipeline 儲存空間
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = local.artifact_bucket_name
}
resource "aws_s3_bucket_lifecycle_configuration" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  rule {
    id      = "artifacts"
    status = "Enabled"

    // 只保存一天就刪除
    expiration {
      days = 1
    }
  }
}

resource "aws_codebuild_project" "_" {
  name         = local.codebuild_project_name
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_CUSTOM_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    privileged_mode             = true
  }
}

resource "aws_codepipeline" "cd_pipeline" {
  name     = local.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline_artifacts.bucket
  }

  stage {
    name = "Source"

    action {
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeCommit"
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact"
      ]
      run_order = 1
      version   = "1"

      configuration = {
        "RepositoryName"       = var.repository_name # use custom name of repo
        "BranchName"           = var.git_branch
        "PollForSourceChanges" = true
      }
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      configuration = {
        "ProjectName" = aws_codebuild_project._.name
      }
      input_artifacts = [
        "SourceArtifact"
      ]
      output_artifacts = [
        "BuildArtifact"
      ]
      name             = "Build"
      run_order        = 1
      version          = "1"
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "CodeDeploy"

      input_artifacts = ["BuildArtifact"]
      version         = "1"

      configuration = {
        "ApplicationName"     = var.codedeploy_app_name
        "DeploymentGroupName" = var.deployment_group_name
      }
    }
  }
}

