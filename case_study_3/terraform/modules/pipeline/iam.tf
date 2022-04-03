locals{
  codepipeline_role_name = "${local.pipeline_name}-service-role"
  codebuild_role_name    = "${local.codebuild_project_name}-service-role"
}

resource "aws_iam_role" "codepipeline_role" {
  name = local.codepipeline_role_name

  assume_role_policy = templatefile("./policies/codepipeline_assume_policy.tpl", {})
}

resource "aws_iam_role_policy" "codepipeline_role" {
  name = "${local.codepipeline_role_name}-policy"

  role = aws_iam_role.codepipeline_role.id

  policy = templatefile("./policies/codepipeline_policy.tpl", {})
}

resource "aws_iam_role" "codebuild_role" {
  name               = local.codebuild_role_name
  assume_role_policy = templatefile("./policies/build_role_assume_policy.tpl", {})
}

resource "aws_iam_role_policy" "codebuild_role" {
  name = "${local.codebuild_role_name}-policy"
  role = aws_iam_role.codebuild_role.id
  policy = templatefile("./policies/build_role_policy.tpl", {
    aws_region      = var.aws_region
    artifact_bucket = aws_s3_bucket.pipeline_artifacts.arn
  })
}
