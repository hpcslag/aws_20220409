locals{
    pipeline_artifact_name = "${var.project_name}-pipeline"
    codebuild_project_name = "${var.project_name}-codebuild"
    codepipeline_project_name = "${var.project_name}-codepipeline"
    codecommit_repository_name = "${var.my_repository_name}"
    codepipeline_target_branch = "staging"


    # 使用 web.tf 建置的靜態網站 bucket, 編譯完 export static 後丟過去用的
    static_web_s3_bucket_name = "${aws_s3_bucket.web.bucket}"
    # 使用 web.tf 建置靜態網站的 cloudfront
    static_web_cloudfront_id = "${aws_cloudfront_distribution.web.id}"
}

# Pipeline 儲存空間
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = local.pipeline_artifact_name

  # AWS Provider 4.0.0 don't use it
  // lifecycle_rule {
  //   id      = "artifacts"
  //   enabled = true
    
  //   // 只保存一天就刪除
  //   expiration {
  //     days = 1
  //   }
  // }
}

# AWS Provider 4.0.0 use it to apply lifecycle setting
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

# 建置檔案
# reference to: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project#artifacts
resource "aws_codebuild_project" "_" {
  name         = local.codebuild_project_name
  service_role = aws_iam_role.codebuild_role.arn

  # 產生檔案的類型: NO_ARTIFACTS or CODEPIPELINE
  artifacts {
    type = "CODEPIPELINE"
  }

  // 設定來源, 從 CODEPIPELINE 的 S3 拿到專案，也可以使用 GITHUB, ...etc
  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
  }

  // 快取資料存哪裡: LOCAL or S3
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_CUSTOM_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  # 執行 codebuild (建置) 機器環境類型
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    # 可以自訂環境變數帶入
    environment_variable {
      name  = "STATIC_ASSETS_BUCKET"
      # 使用 web.tf 建置的靜態網站 bucket, 編譯完 export static 後丟過去用的
      value = local.static_web_s3_bucket_name
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION"
      # 使用 web.tf 建置靜態網站的 cloudfront
      value = local.static_web_cloudfront_id
    }

    environment_variable {
      name  = "DEPLOY_SCRIPT"
      value = "deploy:staging"
    }
  }
}

# 建立 Pipeline 過程
resource "aws_codepipeline" "static_pipeline" {
  name     = local.codepipeline_project_name
  role_arn = aws_iam_role.codepipeline_role.arn

  # 把編譯的檔案資料都丟到這個空間去
  artifact_store {
    type     = "S3"
    # 使用最上面建立的 pipeline 儲存空間
    location = aws_s3_bucket.pipeline_artifacts.bucket
  }

  # 設定階段一
  stage {
    # 階段名稱
    name = "PutSource" 

    # 設定動作: 把 CodeCommit 檔案丟到 S3 Artifacts, aws_codebuild_project._.source 就會用這裡的檔案處理
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
        "RepositoryName"       = local.codecommit_repository_name
        "BranchName"           = local.codepipeline_target_branch
        "PollForSourceChanges" = true
      }
    }
  }

  # 階段二，建置過程
  stage {
    name = "BuildProject"

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
      name             = "Build"
      output_artifacts = []
      run_order        = 1
      version          = "1"
    }
  }
}