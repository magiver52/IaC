resource "aws_cloudfront_origin_access_control" "oac" {
  count                             = length(var.cloudfront_config) > 0 ? length(var.cloudfront_config) : 0
  name                              = join("-", tolist([var.client, var.functionality, var.environment, "oac", var.cloudfront_config[count.index].application, count.index + 1]))
  description                       = var.cloudfront_config[count.index].oac_description
  origin_access_control_origin_type = var.cloudfront_config[count.index].oac_origin
  signing_behavior                  = var.cloudfront_config[count.index].oac_signing_behavior
  signing_protocol                  = var.cloudfront_config[count.index].oac_signing_protocol
}

resource "aws_cloudfront_distribution" "cloudfront" {
  count               = length(var.cloudfront_config) > 0 ? length(var.cloudfront_config) : 0
  web_acl_id          = var.cloudfront_config[count.index].web_acl_id
  comment             = var.cloudfront_config[count.index].comment
  default_root_object = var.cloudfront_config[count.index].default_root_object
  enabled             = var.cloudfront_config[count.index].enabled
  http_version        = var.cloudfront_config[count.index].http_version
  aliases             = var.cloudfront_config[count.index].aliases
  price_class         = var.cloudfront_config[count.index].price_class

  dynamic "custom_error_response" {
    for_each = var.cloudfront_config[count.index].custom_error_responses
    content {
      error_caching_min_ttl = custom_error_response.value["error_caching_min_ttl"]
      error_code            = custom_error_response.value["error_code"]
      response_code         = custom_error_response.value["response_code"]
      response_page_path    = custom_error_response.value["response_page_path"]
    }
  }

  dynamic "origin" {
    for_each = var.cloudfront_config[count.index].s3_origin
    content {
      origin_id                = origin.value["origin_id"]
      domain_name              = origin.value["domain_name"]
      origin_path              = origin.value["origin_path"]
      origin_access_control_id = aws_cloudfront_origin_access_control.oac[count.index].id
    }

  }

  default_cache_behavior {
    allowed_methods            = var.cloudfront_config[count.index].default_allowed_methods
    cached_methods             = var.cloudfront_config[count.index].default_cached_methods
    target_origin_id           = var.cloudfront_config[count.index].default_target_origin
    viewer_protocol_policy     = var.cloudfront_config[count.index].default_viewer_protocol_policy
    cache_policy_id            = var.cloudfront_config[count.index].default_cache_policy_id
    response_headers_policy_id = var.cloudfront_config[count.index].default_response_headers_policy_id
    compress                   = var.cloudfront_config[count.index].default_compress
    dynamic "function_association" {
      for_each = var.cloudfront_config[count.index].default_function_association
      content {
        event_type   = function_association.value["event_type"]
        function_arn = function_association.value["function_arn"]
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.cloudfront_config[count.index].ordered_cache_behavior
    content {
      path_pattern               = ordered_cache_behavior.value["path_pattern"]
      allowed_methods            = ordered_cache_behavior.value["allowed_methods"]
      cached_methods             = ordered_cache_behavior.value["cached_methods"]
      target_origin_id           = ordered_cache_behavior.value["target_origin_id"]
      viewer_protocol_policy     = ordered_cache_behavior.value["viewer_protocol_policy"]
      cache_policy_id            = ordered_cache_behavior.value["cache_policy_id"]
      response_headers_policy_id = ordered_cache_behavior.value["response_headers_policy_id"]
      compress                   = ordered_cache_behavior.value["compress"]
      dynamic "function_association" {
        for_each = ordered_cache_behavior.value["function_association"]
        content {
          event_type   = function_association.value["event_type"]
          function_arn = function_association.value["function_arn"]
        }
      }
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.cloudfront_config[count.index].viewer_certificate
    content {
      acm_certificate_arn            = viewer_certificate.value["acm_certificate_arn"]
      cloudfront_default_certificate = viewer_certificate.value["acm_certificate_arn"] == "" ? true : false
      minimum_protocol_version       = viewer_certificate.value["minimum_protocol_version"]
      ssl_support_method             = viewer_certificate.value["ssl_support_method"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_config[count.index].restriction_type
    }
  }

  tags = merge({ Name = "${join("-", tolist([var.client, var.functionality, var.environment, "cloudfront", var.cloudfront_config[count.index].application, count.index + 1]))}" },
  { id_case = var.cloudfront_config[count.index].ticket })
}
