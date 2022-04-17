# Root pipeline resource
resource "aws_imagebuilder_image_pipeline" "main" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.main.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.main.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.main.arn
  enhanced_image_metadata_enabled  = var.imgpipe_EIM_enabled
  name                             = var.imgb_stackname
  description                      = var.imgpipe_description
  tags                             = var.imgpipe_tags
  status                           = var.imgpipe_status

  dynamic "schedule" {
    for_each = var.imgpipe_schedule

    content {
      schedule_expression                = schedule.value.schedule_expression
      pipeline_execution_start_condition = schedule.value.pipeline_execution_start_condition
      timezone                           = schedule.value.timezone
    }
  }

  image_tests_configuration {
    image_tests_enabled = var.imgpipe_tests_enabled
    timeout_minutes     = var.imgpipe_timeout_mins
  }
}

# Conditional image creation at TF runtime
resource "aws_imagebuilder_image" "main" {
  count = var.imgb_create_image_now ? 1 : 0

  image_recipe_arn                 = aws_imagebuilder_image_recipe.main.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.main.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.main.arn
  enhanced_image_metadata_enabled  = var.imgpipe_EIM_enabled

  image_tests_configuration {
    image_tests_enabled = var.imgpipe_tests_enabled
    timeout_minutes     = var.imgpipe_timeout_mins
  }

  timeouts {
    create = var.imgb_image_timeout
  }
}

# Handles image building, testing
resource "aws_imagebuilder_infrastructure_configuration" "main" {
  description                   = var.imginfracfg_description
  instance_profile_name         = var.imgb_custom_instance_profile != "" ? var.imgb_custom_instance_profile : aws_iam_instance_profile.main[0].id
  instance_types                = var.imginfracfg_instance_types
  key_pair                      = var.imginfracfg_keypair
  name                          = var.imgb_stackname
  security_group_ids            = var.imginfracfg_sg_ids
  sns_topic_arn                 = var.imginfracfg_sns_topic_arn
  subnet_id                     = var.imginfracfg_subnet_id
  terminate_instance_on_failure = var.imginfracfg_term_on_fail

  dynamic "logging" {
    for_each = var.imginfracfg_logging
    content {
      s3_logs {
        s3_bucket_name = logging.value.s3_bucket_name
        s3_key_prefix  = logging.value.s3_key_prefix
      }
    }
  }

  tags = var.imginfracfg_tags
}

# Represents a collection of custom components managed within the stack
resource "aws_imagebuilder_component" "main" {
  for_each = var.imgb_components

  name                  = each.key
  data                  = each.value.data != null ? file("${path.root}/${each.value.data}") : null
  uri                   = each.value.uri
  platform              = each.value.platform
  version               = each.value.version
  change_description    = each.value.change_description
  description           = each.value.description
  kms_key_id            = each.value.kms_key_id
  supported_os_versions = each.value.supported_os_versions
  tags                  = each.value.tags
}

# Handles image distribution
resource "aws_imagebuilder_distribution_configuration" "main" {
  name        = var.imgb_stackname
  description = var.imgdistcfg_description
  tags        = var.imgdistcfg_tags

  dynamic "distribution" {
    for_each = var.imgdistcfg_distribution

    content {
      region                     = distribution.value.region
      license_configuration_arns = distribution.value.license_configuration_arns

      dynamic "launch_template_configuration" {
        for_each = distribution.value.launch_template_cfg != null ? [0] : []

        content {
          default            = distribution.value.launch_template_cfg.default
          launch_template_id = distribution.value.launch_template_cfg.launch_template_id
          account_id         = distribution.value.launch_template_cfg.account_id
        }
      }

      dynamic "ami_distribution_configuration" {
        for_each = distribution.value.ami_dist_cfg != null ? [0] : []

        content {
          ami_tags           = distribution.value.ami_dist_cfg.ami_tags
          name               = distribution.value.ami_dist_cfg.name == "{{imagebuilder:buildDate}}" ? "${var.imgb_stackname} {{imagebuilder:buildDate}}" : distribution.value.ami_dist_cfg.name
          description        = distribution.value.ami_dist_cfg.description
          kms_key_id         = distribution.value.ami_dist_cfg.kms_key_id
          target_account_ids = distribution.value.ami_dist_cfg.target_account_ids

          dynamic "launch_permission" {
            for_each = distribution.value.ami_dist_cfg.launch_permission != null ? [0] : []

            content {
              user_ids                 = launch_permission.value.user_ids
              user_groups              = launch_permission.value.user_groups
              organization_arns        = launch_permission.value.organization_arns
              organizational_unit_arns = launch_permission.value.organizational_unit_arns
            }
          }
        }
      }
    }
  }
}

# Creates the image recipe from constituent components
resource "aws_imagebuilder_image_recipe" "main" {
  name              = var.imgb_stackname
  version           = var.imgrep_version
  parent_image      = var.imgrep_parent_img
  description       = var.imgrep_description
  working_directory = var.imgrep_working_dir
  user_data_base64  = base64encode(var.imgrep_user_data)
  tags              = var.imgrep_tags

  dynamic "component" {
    for_each = local.ordered_components
    content {
      component_arn = component.value.component_arn

      dynamic "parameter" {
        for_each = component.value.parameters != null ? component.value.parameters : []

        content {
          name  = parameter.value.name
          value = parameter.value.value
        }
      }
    }
  }

  systems_manager_agent {
    uninstall_after_build = var.imgrep_sysmanager_uninstall
  }

  dynamic "block_device_mapping" {
    for_each = var.imgrep_block_device_maps != null ? var.imgrep_block_device_maps : []

    content {
      device_name = block_device_mapping.value.device_name
      dynamic "ebs" {
        for_each = block_device_mapping.value.ebs

        content {
          delete_on_termination = ebs.value.delete_on_termination
          encrypted             = ebs.value.encrypted
          iops                  = ebs.value.iops
          kms_key_id            = ebs.value.kms_key_id
          snapshot_id           = ebs.value.snapshot_id
          volume_size           = ebs.value.volume_size
          volume_type           = ebs.value.volume_type
        }
      }
      no_device    = block_device_mapping.value.no_device
      virtual_name = block_device_mapping.value.virtual_name
    }
  }
}
