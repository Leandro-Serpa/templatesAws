resource "aws_s3_bucket" "bucket" {
  bucket = "infra-bucket-${var.AWS_ACCOUNT_ID}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  public_access_block_configuration {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  ownership_controls {
    rules {
      object_ownership = "BucketOwnerEnforced"
    }
  }

  event_notification {
    event_bridge {
      enabled = true
    }
  }

  metric {
    id = "infra-bucket-${var.AWS_ACCOUNT_ID}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "ssl_only_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
EOF
}
