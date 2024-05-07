resource "aws_dynamodb_table" "dynamo_table" {
  name           = "table_model_dynamo"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "pk"
  range_key      = "sk"
  stream_enabled = false

  attribute {
    name = "pk"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  attribute {
    name = "exemplo_id"
    type = "S"
  }
  attribute {
    name = "exemplo2_id"
    type = "S"
  }
  attribute {
    name = "exemplo3_dt"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  global_secondary_index {
    name               = "table_model_dynamo.exemplo_id"
    hash_key           = "exemplo_id"
    projection_type    = "KEYS_ONLY"
    write_capacity     = 1
    read_capacity      = 1
  }

  global_secondary_index {
    name               = "table_model_dynamo.exemplo2_id"
    hash_key           = "exemplo2_id"
    range_key          = "exemplo3_dt"
    projection_type    = "KEYS_ONLY"
    write_capacity     = 1
    read_capacity      = 1
  }
}
