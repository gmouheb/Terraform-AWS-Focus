data "aws_region" "current" {}   //returns the current region


resource "random_string" "rand" {
  length = 24
  special = false
  upper = false
}

locals {
  namespace = substr(join("-", [var.namespace, random_string.rand.result]),0,24)
}

resource "aws_resourcegroups_group" "resourcegroups_group" {
  name = "${local.namespace}-group"
  resource_query {
    query = <<-JSON
      {
        "ResourceTypeFilters": [
          "AWS::AllSupported"
      ],
      "TagFilters": [
      {
        "Key": "ResourceGroup",
        "Values": ["${local.namespace}"]
      }
      ]
      }
      JSON
  }
}

resource "aws_kms_key" "kms_key" {
  tags = {
    ResourceGroup = local.namespace
  }
}


resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "${local.namespace}-state-bucket"
  force_destroy = var.force_destroy_state

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.kms_key.arn
      }
    }
  }

  tags = {
    ResourceGroup = local.namespace
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


#
# resource "aws_s3_bucket" "s3_bucket" {
#   bucket = "${local.namespace}-state-bucket"
#   force_destroy = var.force_destroy_state  // this will delete the bucket even if it contains objects!
#
#   # versioning {
#   #   enabled = true
#   # }   Deprecated !!!
# }
#
# resource "aws_s3_bucket_versioning" "s3_versioning" {
#   bucket = aws_s3_bucket.s3_bucket.id
#
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
#
#
# resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
#   bucket = aws_s3_bucket.s3_bucket.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "aws:kms"
#       kms_master_key_id = aws_kms_key.kms_key.arn
#     }
#   }
#
# }
#
# resource "aws_s3_bucket_public_access_block" "s3_bucket" {
#   bucket =  aws_s3_bucket.s3_bucket.id
#
#   block_public_acls = true
#   block_public_policy = true
#   ignore_public_acls = true
#   restrict_public_buckets = true
# }


resource "aws_dynamodb_table" "dynamodb_table" {
  name = "${local.namespace}-state-lock"
  hash_key = "LockID"   //Primary key (partition key)
  billing_mode = "PAY_PER_REQUEST"  //make the db serverless instead of provisioned. u pay for W/R only.
  attribute {
    name = "LockID"
    type = "S"  //S -> String
  }

  tags = {
    ResourceGroup = local.namespace
  }
}

















