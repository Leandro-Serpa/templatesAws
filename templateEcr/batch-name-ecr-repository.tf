resource "aws_ssm_parameter" "develop_id" {
  name  = "DevelopId"
  type  = "String"
  value = "/accounts/development"
}

resource "aws_ecr_repository" "ecr_name" {
  name                 = "batch-name-repo"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_tag_mutability = "IMMUTABLE"

  policy = jsonencode({
    "Version"   : "2012-10-17",
    "Statement" : [
      {
        "Sid"     : "AllowPull",
        "Effect"  : "Allow",
        "Principal": {
          "AWS": [
            "${aws_ssm_parameter.develop_id.value}"
          ]
        },
        "Action"  : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })

  lifecycle_policy = jsonencode({
    "rules": [
      {
        "action": {
          "type": "expire"
        },
        "selection": {
          "countType": "imageCountMoreThan",
          "countNumber": 2,
          "tagStatus": "tagged",
          "tagPrefixList": [
            "develop-"
          ]
        },
        "description": "Remove develop- images",
        "rulePriority": 1
      }              
    ]
  })
}
