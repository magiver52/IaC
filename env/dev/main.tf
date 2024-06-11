####################################################################
# Modulos Principal VPC
####################################################################
module "vpc" {
  source        = "../../modules/VPC"
  client        = var.client
  environment   = var.environment
  functionality = var.functionality
  tags          = var.tags
  create_vpc    = true

  vpc_config = {
    cidr_block = "10.0.0.0/16"
  }

  subnets = [
    {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = false
      tipo_subnet             = "private"
    },
    {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "us-east-1b"
      map_public_ip_on_launch = false
      tipo_subnet             = "private"
    },
    {
      cidr_block              = "10.0.3.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
      tipo_subnet             = "public"
    },
    {
      cidr_block              = "10.0.4.0/24"
      availability_zone       = "us-east-1b"
      map_public_ip_on_launch = true
      tipo_subnet             = "public"
    },
    {
      cidr_block              = "10.0.5.0/24"
      availability_zone       = "us-east-1c"
      map_public_ip_on_launch = true
      tipo_subnet             = "private"
    }
  ]
}

####################################################################
# Modulos Principal VPC - si la VPC ya existe
####################################################################

# module "vpc" {
#   source        = "../../modules/VPC"
#   client        = var.client
#   environment   = var.environment
#   functionality = var.functionality
#   tags          = var.tags
#   create_vpc    = false

#   existing_vpc_id = "vpc-12345678" # Se pasa el ID de la VPC

#   subnets = [
#     {
#       cidr_block              = "10.0.1.0/24"
#       availability_zone       = "us-east-2a"
#       map_public_ip_on_launch = false
#       tipo_subnet             = "private"
#     },
#     {
#       cidr_block              = "10.0.2.0/24"
#       availability_zone       = "us-east-2b"
#       map_public_ip_on_launch = false
#       tipo_subnet             = "private"
#     },
#     {
#       cidr_block              = "10.0.3.0/24"
#       availability_zone       = "us-east-2c"
#       map_public_ip_on_launch = true
#       tipo_subnet             = "public"
#     }
#   ]
# }

####################################################################
# Modulos Principal S3
####################################################################
module "s3" {
  source        = "../../modules/S3/"
  client        = var.client
  functionality = var.functionality
  environment   = var.environment
  s3_config     = var.s3_config
  tags          = var.tags
}

####################################################################
# Modulos IAM - Role Lambda Prueba
####################################################################
module "iam_role_app02" {
  source      = "../../modules/IAM"
  client      = "pragma"
  environment = "dev"
  iam_config = [
    {
      project     = "banesco"
      application = "app02"
      path        = "/"
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
      ticket      = "0001"
      policies = [
        {
          policy_description = "policy for sqs and cw-logs service"
          policy_statements = [
            {
              sid = "sqsPermission1"
              actions = [
                "sqs:SendMessage"
              ]
              resources = [

                "arn:aws:sqs:*:298782619489:*"
              ]
              effect    = "Allow"
              condition = []
            },

            {
              sid = "cloudwatchlogsPermission1"
              actions = [
                "logs:CreateLogGroup"

              ]
              resources = [
                "arn:aws:logs:us-east-1:298782619489:*"
              ]
              effect    = "Allow"
              condition = []
            },

            {
              sid = "cloudwatchlogsPermission2"
              actions = [
                "logs:CreateLogStream",
                "logs:PutLogEvents"

              ]
              resources = [
                "arn:aws:logs:us-east-1:298782619489:log-group:/aws/lambda/obtenerResultadosporIdOEmail:*",
                "arn:aws:logs:*:298782619489:log-group:*:log-stream:*"
              ]
              effect    = "Allow"
              condition = []
            },

            {
              sid = "ec2Permission1"
              actions = [
                "dynamodb:BatchGetItem",
                "dynamodb:GetShardIterator",
                "dynamodb:GetItem",
                "ec2:*",
                "dynamodb:List*",
                "dynamodb:GetResourcePolicy",
                "dynamodb:GetRecords"

              ]
              resources = [
                "*"
              ]
              effect    = "Allow"
              condition = []
            }
          ]
        }

      ]
    }
  ]
}

####################################################################
# Modulos Principal Lambda Prueba
####################################################################
module "lambda_app02" {
  source      = "../../modules/LAMBDAS"
  client      = "pragma"
  project     = "banesco"
  environment = "dev"
  lambda_config = [
    {
      s3_bucket   = "banesco-back-s3"
      s3_key      = "app02/app02.zip"
      description = "Codigo Lambda de Prueba"
      role        = module.iam_role_app02.iam_role_info["app02"]["role_arn"]
      handler     = "app02"
      memory_size = "512"
      runtime     = "nodejs18.x"
      timeout     = "300"
      application = "app02"
      vpc_config = [{
        security_group_ids = ["sg-0500a18efc8d5b653"]

        subnet_ids = ["subnet-05d47d8a3a28bb638", "subnet-0cb097ccadaeb7098"]
      }]
    },
  ]
  depends_on = [module.iam_role_app02]
}

module "kms_s3" {
  source = "../../modules/KMS"
  #source = "./kms"
  kms_config = [
    {
      description         = "KMS for s3 encryption"
      enable_key_rotation = true
      statements = [

        {
          sid = "kms_users"
          actions = [
            "kms:Create*",
            "kms:Describe*",
            "kms:Enable*",
            "kms:List*",
            "kms:Put*",
            "kms:Update*",
            "kms:Revoke*",
            "kms:Disable*",
            "kms:Get*",
            "kms:Decrypt",
            "kms:Encrypt",
            "kms:GenerateDataKey",
            "kms:Delete*",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion"
          ]
          resources   = ["*"]
          effect      = "Allow"
          type        = "Federated"
          identifiers = ["arn:aws:iam::840021737375:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_6655beebac0a3b6f"]
          condition   = []
        },
        {
          sid = "kms_cloudfront"
          actions = [
            "kms:Decrypt",
            "kms:Encrypt",
            "kms:GenerateDataKey"
          ]
          resources   = ["*"]
          effect      = "Allow"
          type        = "Service"
          identifiers = ["cloudfront.amazonaws.com"]
          condition = [
            {
              test     = "StringLike"
              variable = "AWS:SourceArn"
              values   = ["arn:aws:cloudfront::840021737375:distribution/*"]
            }
          ]

        }
      ]
      ticket      = "1234"
      application = var.application
    }
  ]
  client        = var.client
  functionality = var.functionality
  environment   = var.environment
  cost_center   = var.cost_center
  owner         = var.owner
  area          = var.area
  tags          = var.tags
}


module "s3_dev" {
  source        = "../../modules/S3-CDN"
  client        = var.client
  functionality = var.functionality
  environment   = var.environment
  s3_config = [
    {
      ticket      = "1234"
      application = "cdn"
      kms_key_id  = module.kms_s3.kms_info[0]["key_id"]
      accessclass = "private"
      versioning  = "Enabled"
      statements = [
        {
          sid = "PolicyForCloudFrontPrivateContent"
          actions = [
            "s3:GetObject"
          ]
          effect      = "Allow"
          type        = "Service"
          identifiers = ["cloudfront.amazonaws.com"]
          condition = [
            /*
                        {
                            test = "StringEquals"
                            variable = "AWS:SourceArn"
                            values = ["arn:aws:cloudfront::${local.common_vars.inputs.account}:distribution/E9AHCQ8APS2WQ"]
                        }*/
          ]
        }
      ]
    }
  ]
}


module "cloudfront_dev" {
  source        = "../../modules/CLOUDFRONT"
  client        = var.client
  functionality = var.functionality
  environment   = var.environment
  cloudfront_config = [
    {
      oac_description      = "OAC For S3 Encryption"
      oac_origin           = "s3"
      oac_signing_behavior = "always"
      oac_signing_protocol = "sigv4"
      web_acl_id           = ""
      comment              = "Cloudfront For Assessment"
      default_root_object  = ""
      enabled              = true
      http_version         = "http2"
      aliases              = []
      price_class          = "PriceClass_All"
      custom_error_responses = [
        {
          error_caching_min_ttl = "0"
          error_code            = "400"
          response_code         = "200"
          response_page_path    = "/index.html"
        },

        {
          error_caching_min_ttl = "0"
          error_code            = "403"
          response_code         = "200"
          response_page_path    = "/index.html"
        },
        {
          error_caching_min_ttl = "0"
          error_code            = "404"
          response_code         = "200"
          response_page_path    = "/index.html"
        }

      ]
      s3_origin = [
        {
          origin_id   = "s3-cdn"
          domain_name = module.s3_dev.s3_info["cdn"]["s3_domain_name"]
          origin_path = "" # Optional: leave empty if the entire bucket is the origin
        }
      ]
      default_allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      default_cached_methods             = ["GET", "HEAD", "OPTIONS"]
      default_target_origin              = "s3-cdn"
      default_viewer_protocol_policy     = "redirect-to-https"
      default_cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      default_response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c"
      default_compress                   = true
      default_function_association       = []
      ordered_cache_behavior = [
      ]
      viewer_certificate = [
        {
          acm_certificate_arn      = ""
          minimum_protocol_version = "TLSv1"
          ssl_support_method       = "sni-only"
        }
      ]
      restriction_type = "none"
      ticket           = "1234"
      application      = var.application
    }
  ]
  depends_on = [module.s3_dev]
}
