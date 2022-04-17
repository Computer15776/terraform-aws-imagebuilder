locals {
  # Create set of S3 bucket ARNs from the names derived from logging attribute objects
  s3_buckets = toset([for o in var.imginfracfg_logging : "arn:aws:s3:::${o.s3_logs.s3_bucket_name}/*"])

  # Create a joined set of component objects from both the managed and created components, derived from their respective input variables 
  components = concat([for k, o in var.imgb_components : {
    component_arn = aws_imagebuilder_component.main[k].id
    parameters    = o.parameters != null ? o.parameters : null
    order         = o.order
    }], [for k, o in var.imgb_aws_components : {
    component_arn = o.arn
    parameters    = o.parameters != null ? o.parameters : null
    order         = o.order
    }]
  )

  # A list of values from map of objects ordered numerically by the original order attr of local.components so components are ran in the correct order
  ordered_components = values({ for o in local.components : o.order =>
    {
      component_arn = o.component_arn
      parameters    = o.parameters
    }
  })
}

terraform {
  # Required for optional attributes on objects to work in any sane manner
  experiments      = [module_variable_optional_attrs]
  required_version = ">= 1.1.0"
  required_providers {
    aws = ">= 4.9.0"
  }
}
