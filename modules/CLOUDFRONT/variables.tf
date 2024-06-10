variable "cloudfront_config" {
  type = list(object({
    oac_description      = string
    oac_origin           = string
    oac_signing_behavior = string
    oac_signing_protocol = string
    web_acl_id           = string
    comment              = string
    default_root_object  = string
    enabled              = bool
    http_version         = string
    aliases              = list(string)
    price_class          = string
    custom_error_responses = list(object({
      error_caching_min_ttl = string
      error_code            = string
      response_code         = string
      response_page_path    = string
    }))
    s3_origin = list(object({
      domain_name = string
      origin_id   = string
      origin_path = string
    }))
    default_allowed_methods            = list(string)
    default_cached_methods             = list(string)
    default_target_origin              = string
    default_viewer_protocol_policy     = string
    default_cache_policy_id            = string
    default_response_headers_policy_id = string
    default_compress                   = bool
    default_function_association = list(object({
      event_type   = string
      function_arn = string
    }))
    ordered_cache_behavior = list(object({
      path_pattern               = string
      allowed_methods            = list(string)
      cached_methods             = list(string)
      target_origin_id           = string
      viewer_protocol_policy     = string
      cache_policy_id            = string
      response_headers_policy_id = string
      compress                   = bool
      function_association = list(object({
        event_type   = string
        function_arn = string
      }))
    }))
    viewer_certificate = list(object({
      acm_certificate_arn      = string
      minimum_protocol_version = string
      ssl_support_method       = string
    }))
    restriction_type = string
    ticket           = string
    application      = string
  }))
}

variable "functionality" {
  type = string
}

variable "client" {
  type = string
}

variable "environment" {
  type = string
}
