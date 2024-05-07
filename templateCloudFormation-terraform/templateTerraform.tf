# Main template for Onboarding domain

variable "vpc_endpoint_old" {
  type        = string
  description = "VPC endpoint for API Gateway execute"
}

variable "vpc_endpoint" {
  type        = string
  description = "VPC endpoint for API Gateway execute"
}

variable "secret_write_arn" {
  type        = string
  description = "Secrets Manager with write permission to Aurora"
}

variable "secret_read_arn" {
  type        = string
  description = "Secrets Manager with write permission to Aurora"
}

variable "lambda_security_group_id" {
  type = string
}

variable "lambda_subnet_ids" {
  type = list(string)
}

variable "code_deploy_role_arn" {
  type        = string
  description = "Role utilized by CodeDeploy to deploy the package to Lambda"
}

variable "proxy_resource_id" {
  type        = string
  description = "RDS Proxy resource ID. This is the last part of RDS Proxy ARN, e.g., prx-<hash>. It's required to configure the necessary permissions by the Lambda functions."
}

variable "event_bus_name" {
  type        = string
  description = "EventBus name"
}

variable "env_type" {
  type = string
}

variable "pismo_credential_secret" {
  type        = string
  description = "Secret to get Pismo credentials"
}

variable "pismo_kms_sign" {
  type        = string
  description = "KMS to sign Pismo client"
}

variable "pismo_pla_customer" {
  type        = string
  description = "Secret to validate crypto"
}

variable "pool_id" {
  type        = string
  description = "Cognito Pool Id"
}

resource "aws_apigatewayv2_api" "rest_api" {
  name          = "OnboardingDomainAPI"
  protocol_type = "HTTP"
  # Add other required properties here
}

resource "aws_logs_log_group" "onboarding_log_group" {
  name = "apigateway/onboarding"
}

resource "aws_iam_role" "api_role" {
  name = "OnboardingDomainApiRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  policy {
    name   = "AllowStartSyncExecution"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "states:StartSyncExecution",
            "states:StartExecution"
          ]
          Resource = ["arn:aws:states:*:*:stateMachine:stp-onb-*"]
        }
      ]
    })
  }
}

# Define the SQS dlq
resource "aws_sqs_queue" "onboarding_create_onboarding_queue_dlq" {
  name = "onboarding-create_onboarding-dlq"
}

# Define the SQS queue
resource "aws_sqs_queue" "onboarding_create_onboarding_queue" {
  name              = "onboarding-create_onboarding-queue"
  visibility_timeout = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.onboarding_create_onboarding_queue_dlq.arn
    maxReceiveCount     = 1
  })
}

resource "aws_sqs_queue_policy" "onboarding_create_onboarding_queue_policy" {
  queue_url = aws_sqs_queue.onboarding_create_onboarding_queue.id

  policy = jsonencode({
    Version    = "2012-10-17",
    Id         = "OnboardingCreateOnboardingQueuePolicy",
    Statement  = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "SQS:SendMessage",
        Resource  = aws_sqs_queue.onboarding_create_onboarding_queue.arn
      }
    ]
  })
}

# Define the Lambda function
resource "aws_lambda_function" "lmb_onb_create_onboarding" {
  function_name    = "lmb-onb-create_onboarding"
  description      = "Onboarding Domain lmb-onb-create_onboarding Function"
  runtime          = "nodejs16.x"
  memory_size      = 513
  timeout          = 15
  handler          = "index.handler"
  role             = aws_iam_role.api_role.arn
  source_code_hash = filebase64sha256("./lmb-onb-create_onboarding")

  vpc_config {
    security_group_ids = [var.lambda_security_group_id]
    subnet_ids         = var.lambda_subnet_ids
  }

  environment {
    variables = {
      NODE_ENV       = "production"
      LOG_LEVEL      = "info"
      NODE_OPTIONS  = "--enable-source-maps"
      EVENT_BUS_NAME = var.event_bus_name
      POOL_ID       = var.pool_id
      SCHEMA_REGISTRY_NAME = "onefpay-main-schemaRegistry"
    }
  }

  # Add other required properties here
}

# Define the Lambda function
resource "aws_lambda_function" "lmb_onb_create_credit_analysis" {
  function_name    = "lmb-onb-create_credit_analysis"
  description      = "Onboarding Domain lmb-onb-create_credit_analysis Function"
  runtime          = "nodejs16.x"
  memory_size      = 513
  timeout          = 15
  handler          = "index.handler"
  role             = aws_iam_role.api_role.arn
  source_code_hash = filebase64sha256("./lmb-onb-create_credit_analysis")

  vpc_config {
    security_group_ids = [var.lambda_security_group_id]
    subnet_ids         = var.lambda_subnet_ids
  }

  environment {
    variables = {
      NODE_ENV       = "production"
      LOG_LEVEL      = "info"
      NODE_OPTIONS  = "--enable-source-maps"
      EVENT_BUS_NAME = var.event_bus_name
      POOL_ID       = var.pool_id
      SCHEMA_REGISTRY_NAME = "onefpay-main-schemaRegistry"
    }
  }

  # Add other required properties here
}
