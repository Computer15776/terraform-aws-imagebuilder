## General vars
variable "region" {
  description = "The region to create the resources from this module."
  default     = "us-east-1"
  type        = string
}

variable "imgb_stackname" {
  description = "The name for the image builder stack. This is used for naming the resources deployed by this module."
  type        = string
}

## IAM Vars
variable "imgb_managed_policies" {
  description = "A set of managed IAM policy ARNs to attach to the image builder instances. This should include EC2InstanceProfileForImageBuilder, EC2InstanceProfileForImageBuilderECRContainerBuilds, AmazonSSMManagedInstanceCore at a minimum."
  type        = set(string)
  default     = ["arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder", "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

variable "imgb_custom_policy" {
  description = "A string containing the full custom policy to apply to the role in addition to the managed policies. Leave default to forgo creation of the custom IAM policy resource."
  type        = string
  default     = ""
}

variable "imgb_custom_instance_profile" {
  description = "A string representing the ARN of a custom instance profile to use in place of one created by this module. Leave default to use the module-created resource."
  type        = string
  default     = ""
}

variable "imgb_custom_iam_role" {
  description = "A string representing the ARN of a custom IAM role to use in place of one created by this module. Leave default to use the module-created resource."
  type        = string
  default     = ""
}

## Image Resource vars
variable "imgb_create_image_now" {
  description = "WARNING significantly increased TF deployment times. A boolean to determine whether or not to create an image at the time of running Terraform in addition to any automated schedule configured."
  type        = bool
  default     = false
}

variable "imgb_image_timeout" {
  description = "String representation of a duration i.e. 60m for 60 minutes or 2h for 2 hours, for Terraform to wait for the image to be built, tested, and distributed."
  type        = string
  default     = null
}

## Image Pipeline vars
variable "imgpipe_description" {
  description = "A description for the EC2 image builder pipeline."
  type        = string
  default     = null
}

variable "imgpipe_tags" {
  description = "A map of key-value pairs to override the default tags on the image pipeline."
  type        = map(string)
  default     = null
}

variable "imgpipe_EIM_enabled" {
  description = "Enable or disable Enhanced Image Metadata."
  type        = bool
  default     = true
}

variable "imgpipe_status" {
  description = "Enable or disable the image builder pipeline."
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.imgpipe_status)
    error_message = "The pipeline status must be a string; either ENABLED or DISABLED."
  }
}

variable "imgpipe_schedule" {
  description = "The cron schedule, timezone, and pipeline execution start condition object. Leave default for manual running of the pipeline. Default timezone parameter = UTC"
  type = set(object({
    schedule_expression                = string
    pipeline_execution_start_condition = optional(string)
    timezone                           = optional(string)
  }))
  default = []
}

variable "imgpipe_tests_enabled" {
  description = "Enable or disable image tests. True will enable tests, False will disable tests."
  type        = bool
  default     = true
}

variable "imgpipe_timeout_mins" {
  description = "The maximum threshold in minutes for the image testing to timeout and fail. Must be between 60 and 1440 (1 and 24 hours)."
  type        = number
  default     = 720

  validation {
    condition     = var.imgpipe_timeout_mins >= 60 && var.imgpipe_timeout_mins <= 1440
    error_message = "Value must be between 60 and 1440 inclusive."
  }
}

## Infrastructure Configuration vars
variable "imginfracfg_description" {
  description = "A description for the EC2 image builder infrastructure configuration."
  type        = string
  default     = null
}

variable "imginfracfg_instance_types" {
  description = "A set of EC2 instance types to use for building the image."
  type        = set(string)
  default     = null
}

variable "imginfracfg_keypair" {
  description = "The name of an EC2 key pair in order to connect to image builder worker instances. Leave default for no key pairs - SSM Session Manager can still be used if available."
  type        = string
  default     = null
}

variable "imginfracfg_sg_ids" {
  description = "A set of EC2 security group identifiers to attach to image builder worker instances. Leave default to use the default security group."
  type        = set(string)
  default     = null
}

variable "imginfracfg_sns_topic_arn" {
  description = "The ARN of an SNS topic for the infrastructure configuration."
  type        = string
  default     = null
}

variable "imginfracfg_subnet_id" {
  description = "The EC2 subnet identifier to use during building and testing. WARNING You must also set imginfracfg_sg_ids so the instance has security groups attached."
  type        = string
  default     = null
}

variable "imginfracfg_term_on_fail" {
  description = "Terminate EC2 instance on build failure - True will terminate on failure and False will retain the instance. Defaults to True."
  type        = bool
  default     = true
}

variable "imginfracfg_logging" {
  description = "A set of objects containing logging options for the infrastructure configuration. Leave default for no logging."
  type = set(object({
    s3_logs = object({
      s3_bucket_name = string
      s3_key_prefix  = optional(string)
    })
  }))
  default = []
}

variable "imginfracfg_tags" {
  description = "A map of key-value pairs to override the default tags on the infrastructure configuration."
  type        = map(string)
  default     = null
}

## Builder component vars
variable "imgb_components" {
  description = "A map of objects with each object representing an image builder component to create. If specifying the `data` attribute, this should be in the form of a relative path to the root module i.e. data/component1.yaml and is mutually exclusive with `uri`."
  type = map(object({
    data                  = optional(string)
    uri                   = optional(string)
    platform              = string
    version               = string
    description           = optional(string)
    change_description    = optional(string)
    kms_key_id            = optional(string)
    supported_os_versions = optional(set(string))
    tags                  = optional(map(string))
    parameters = optional(list(object({
      name  = string
      value = list(string)
    })))
    order = optional(number)
  }))
  default = {}
  validation {
    condition     = alltrue([for k, o in var.imgb_components : o.order > 0 ? true : false])
    error_message = "Order values must be greater than 0."
  }
}

variable "imgb_aws_components" {
  description = "A map of objects with each object representing a pre-existing image builder component. To be used with managed AWS, shared, or other preexisting components you would like to reuse that aren't managed by this stack."
  type = map(object({
    arn = string
    parameters = optional(list(object({
      name  = string
      value = list(string)
    })))
    order = optional(number)
  }))
  default = {}
  validation {
    condition     = alltrue([for k, o in var.imgb_aws_components : o.order > 0 ? true : false])
    error_message = "Order values must be greater than 0."
  }
}

## Distribution Configuration vars
variable "imgdistcfg_description" {
  description = "A description for the EC2 image builder distribution configuration."
  type        = string
  default     = null
}

variable "imgdistcfg_kms_arn" {
  description = "The ARN of a KMS key used to encrypt the distribution configuration."
  type        = string
  default     = null
}

variable "imgdistcfg_tags" {
  description = "A map of key-value pairs to override the default tags on the distribution configuration."
  type        = map(string)
  default     = null
}

variable "imgdistcfg_license_config_arns" {
  description = "A set of License Manager License Configuration ARNs for use with the image builder distribution configuration."
  type        = set(string)
  default     = null
}

variable "imgdistcfg_distribution" {
  description = "A list of AMI distribution configuration objects for the corresponding resource. Defaults to single-AMI output in same region. Custom AMI names MUST contain the AWS variable {{imagebuilder:buildDate}}."
  type = list(object(
    {
      region                     = string
      license_configuration_arns = optional(set(string))
      ami_dist_cfg = optional(object({
        ami_tags           = optional(map(string))
        description        = optional(string)
        kms_key_id         = optional(string)
        name               = optional(string)
        target_account_ids = optional(set(string))
        launch_permission = optional(object({
          user_groups              = optional(set(string))
          user_ids                 = optional(set(string))
          organization_arns        = optional(set(string))
          organizational_unit_arns = optional(set(string))
        }))
      }))
      container_dist_cfg = optional(object({
        container_tags = optional(set(string))
        description    = optional(string)
        target_repo = object({
          repository_name = string
          service         = string
        })
      }))
      launch_template_cfg = optional(object({
        default            = optional(bool)
        launch_template_id = string
        account_id         = optional(string)
      }))
  }))
  default = [{
    region = "us-east-1",
    ami_dist_cfg = {
      name = "{{imagebuilder:buildDate}}"
    }
  }]
  validation {
    # Create a set of object names regexed to match the timestamp interpolation and then if length of result is over 0 (i.e. match found) return true else false (no matches anyway)
    # This creates a set of bool values for each AMI name attr inside the original set of objects, finally compared with alltrue to verify all entries contain the timestamp
    condition     = alltrue([for o in var.imgdistcfg_distribution : length(regexall("{{imagebuilder:buildDate}}", o.ami_dist_cfg.name)) > 0 ? true : false])
    error_message = "Custom AMI names MUST include {{imagebuilder:buildDate}} somewhere within the name string i.e. name = 'AMIname {{imagebuilder:buildDate}}'."
  }
}

## Image recipe vars
variable "imgrep_parent_img" {
  description = "The parent image of this image recipe; either the ARN of the base image or an AMI ID. Version in the image ARN can be included or wildcarded."
  type        = string
}

variable "imgrep_version" {
  description = "The semantic version of the image recipe. Defaults to 1.0.0 but any suitable semantic version is accepted."
  type        = string
  default     = "1.0.0"
}

variable "imgrep_sysmanager_uninstall" {
  description = "Whether to remove the Systems Manager Agent after the image has been built."
  type        = bool
  default     = false
}

variable "imgrep_block_device_maps" {
  description = "A list of block device mappings to apply when creating images. Defaults to no additional block devices."
  type = list(object({
    device_name  = optional(string)
    no_device    = optional(string)
    virtual_name = optional(string)
    ebs = object({
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      iops                  = optional(number)
      kms_key_id            = optional(string)
      snapshot_id           = optional(string)
      throughput            = optional(number)
      volume_size           = optional(number)
      volume_type           = optional(string)
    })
  }))
  default = null
}

variable "imgrep_description" {
  description = "Enter a description for the image recipe."
  type        = string
  default     = null
}

variable "imgrep_tags" {
  description = "A map of key-value pairs to override the default tags on the image recipe."
  type        = map(string)
  default     = null
}

variable "imgrep_working_dir" {
  description = "The working directory to use for build and test workflows."
  type        = string
  default     = null
}

variable "imgrep_user_data" {
  description = "Base64-encoded user data to provide commands when launching your build instance."
  type        = string
  default     = null
}
