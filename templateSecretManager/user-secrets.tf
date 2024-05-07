resource "aws_secretsmanager_secret" "secret_exemplo_viewer" {
  name        = "rds/user/rds_exemplo_viewer"
  description = "Reader party user for Aurora"
  secret_string = jsonencode({
    host     = "rds-read-only.endpoint.proxy-xxxxxxxxxx.sa-east-1.rds.amazonaws.com"
    port     = "0000"
    username = "rds_exemplo_viewer"
    password = "zzzzzzzz"
    database = "exemploDB"
  })

  tags = {
    Name = "rds/user/rds_exemplo_viewer"
  }
}

resource "aws_secretsmanager_secret" "secret_exemplo_writer" {
  name        = "rds/user/rds_exemplo_writer"
  description = "Writer party user for Aurora"
  secret_string = jsonencode({
    host     = "aurora-proxy.proxy-yyyyyyyyy.sa-east-1.rds.amazonaws.com"
    port     = "9999"
    username = "rds_exemplo_writer"
    password = "wwwwwww"
    database = "exemploDB"
  })

  tags = {
    Name = "rds/user/rds_exemplo_writer"
  }
}
