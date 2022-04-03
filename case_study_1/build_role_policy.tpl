{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "${public_bucket}",
                "${public_bucket}/*"
            ],
            "Action": [
                "s3:*"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": ["*"],
            "Action": "cloudfront:CreateInvalidation"
        },
        {
            "Effect": "Allow",
            "Resource": ["*"],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-${aws_region}-*",
                "${artifact_bucket}/*",
                "${artifact_bucket}"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages",
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:CompleteLayerUpload",
                "ecr:GetAuthorizationToken",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:UploadLayerPart"
            ],
            "Resource": [
              "*"
            ]
        },
        {
            "Sid": "EKSREADONLY",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeNodegroup",
                "eks:DescribeUpdate",
                "eks:DescribeCluster",
                "eks:AccessKubernetesApi",
                "eks:DescribeIdentityProviderConfig"
            ],
            "Resource": "*"
        },
        {
            "Effect" : "Allow",
            "Action" : [
                "codecommit:*"
            ],
            "Resource" : [
                "*"
            ]
        }
    ]
}

