resource "aws_s3_bucket" "bucket" {
  for_each = { for item in var.s3_config :
    item.application => {
      "index" : index(var.s3_config, item)
      "application" : item.application
      "accessclass" : item.accessclass
      "ticket" : item.ticket
    }
  }
  bucket = join("-", tolist([var.client, var.functionality, var.environment, "s3", each.key]))
  tags = merge({ Name = "${join("-", tolist([var.client, var.functionality, var.environment, "s3", each.key]))}" },
    { id_case = each.value.ticket },
    { accessclass = each.value.accessclass },
  { application = each.value.application })
}


resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_bucket" {
  for_each = { for item in var.s3_config :
    item.application => {
      "index" : index(var.s3_config, item)
      "application" : item.application
      "kms_key_id" : item.kms_key_id
      "accessclass" : item.accessclass
      "ticket" : item.ticket
    }
  }
  bucket = aws_s3_bucket.bucket[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = each.value.kms_key_id
      sse_algorithm     = "aws:kms"
    }

  }
}


resource "aws_s3_bucket_ownership_controls" "general_ownership" {
  for_each = { for item in var.s3_config :
    item.application => {
      "index" : index(var.s3_config, item)
      "application" : item.application
      "kms_key_id" : item.kms_key_id
      "accessclass" : item.accessclass
      "ticket" : item.ticket
    }
  }
  bucket = aws_s3_bucket.bucket[each.key].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}



# # Recurso Public Acces Block
resource "aws_s3_bucket_public_access_block" "general_public_access" {
  for_each = { for item in var.s3_config :
    item.application => {
      "index" : index(var.s3_config, item)
      "application" : item.application
      "kms_key_id" : item.kms_key_id
      "accessclass" : item.accessclass
      "ticket" : item.ticket
    }
  }
  bucket                  = aws_s3_bucket.bucket[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# # Rescurso habilitando versionamiento.
resource "aws_s3_bucket_versioning" "s3_general_versioning" {
  for_each = { for item in var.s3_config :
    item.application => {
      "index" : index(var.s3_config, item)
      "application" : item.application
      "kms_key_id" : item.kms_key_id
      "versioning" : item.versioning
      "accessclass" : item.accessclass
      "ticket" : item.ticket
    }
  }
  bucket = aws_s3_bucket.bucket[each.key].id
  versioning_configuration {
    status = each.value.versioning
  }
}

# Recurso politica S3
resource "aws_s3_bucket_policy" "policy" {

  for_each = { for item in var.s3_config :
    item.application => {
      "index" : index(var.s3_config, item)
    } if length(item.statements) > 0
  }
  bucket = aws_s3_bucket.bucket[each.key].id
  policy = data.aws_iam_policy_document.dynamic_policy[each.key].json
}

data "aws_iam_policy_document" "dynamic_policy" {
  for_each = { for item in var.s3_config :
    item.application => {
      "index" : index(var.s3_config, item)
      "statements" : item.statements
    } if length(item.statements) > 0
  }
  dynamic "statement" {
    for_each = each.value["statements"]
    content {
      sid       = statement.value["sid"]
      actions   = statement.value["actions"]
      resources = ["arn:aws:s3:::${join("-", tolist([var.client, var.functionality, var.environment, "s3", "${each.key}/*"]))}"]
      effect    = statement.value["effect"]
      principals {
        type        = statement.value["type"]
        identifiers = statement.value["identifiers"]
      }

      dynamic "condition" {
        for_each = statement.value["condition"]
        content {
          test     = condition.value["test"]
          variable = condition.value["variable"]
          values   = condition.value["values"]
        }
      }
    }
  }
}