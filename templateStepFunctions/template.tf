variable "domain" {
  type    = string
  default = ""
}

variable "step_function_name" {
  type    = string
  default = ""
}

resource "aws_cloudwatch_log_group" "stp_log_group_name_exemplo" {
  name = "stepfunction/${var.domain}/stp-${var.domain}-${var.step_function_name}"
}

resource "aws_sfn_state_machine" "state_machine" {
  name       = "stp-${var.domain}-${var.step_function_name}"
  definition = file("./state-machine.json")

  logging_configuration {
    include_execution_data = true
    level                  = "ALL"

    destinations {
      cloudwatch_logs_log_group {
        log_group_arn = aws_cloudwatch_log_group.stp_log_group_name_exemplo.arn
      }
    }
  }

  tracing_configuration {
    enabled = true
  }

  tags = {
    Name = "step_function"
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SubmitJob",
      "Effect": "Allow",
      "Action": "batch:SubmitJob",
      "Resource": "*"
    },
    {
      "Sid": "AllowLogs",
      "Effect": "Allow",
      "Action": "logs:*",
      "Resource": "${aws_cloudwatch_log_group.stp_log_group_name_exemplo.arn}"
    }
  ]
}
POLICY
}
