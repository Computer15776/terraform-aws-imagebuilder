output "pipeline_info" {
  value = {
    arn          = aws_imagebuilder_image_pipeline.main.arn
    date_created = aws_imagebuilder_image_pipeline.main.date_created
    last_run     = aws_imagebuilder_image_pipeline.main.date_last_run
    next_run     = aws_imagebuilder_image_pipeline.main.date_next_run
    platform     = aws_imagebuilder_image_pipeline.main.platform
    tags         = aws_imagebuilder_image_pipeline.main.tags_all
  }
}

output "image_info" {
  value = var.imgb_create_image_now ? {
    arn                  = aws_imagebuilder_image.main[0].arn
    date_created         = aws_imagebuilder_image.main[0].date_created
    platform             = aws_imagebuilder_image.main[0].platform
    os_version           = aws_imagebuilder_image.main[0].os_version
    derivative_resources = aws_imagebuilder_image.main[0].output_resources
    tags                 = aws_imagebuilder_image.main[0].tags_all
    version              = aws_imagebuilder_image.main[0].version
  } : null
}

output "builder_info" {
  value = {
    arn          = aws_imagebuilder_infrastructure_configuration.main.arn
    date_created = aws_imagebuilder_infrastructure_configuration.main.date_created
    date_updated = aws_imagebuilder_infrastructure_configuration.main.date_updated
    tags         = aws_imagebuilder_infrastructure_configuration.main.tags_all
  }
}

output "component_info" {
  value = { for k, v in aws_imagebuilder_component.main : k => {
    component    = k
    arn          = v.arn
    date_created = v.date_created
    encrypted    = v.encrypted
    owner        = v.owner
    tags         = v.tags_all
    type         = v.type
    }
  }
}

output "distribution_info" {
  value = var.imgdistcfg_distribution != [] ? {
    arn          = aws_imagebuilder_distribution_configuration.main.arn
    date_created = aws_imagebuilder_distribution_configuration.main.date_created
    date_updated = aws_imagebuilder_distribution_configuration.main.date_updated
    tags         = aws_imagebuilder_distribution_configuration.main.tags_all
  } : null
}


