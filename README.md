# EC2 Image Builder Pipeline Module

## 📕 Description 

This module is designed to provide a full EC2 Image Builder workflow from pipeline creation through to generation of the AMI itself. It is also designed to be highly customizable by exposing most configuration attributes of the underlying resources; while at the same time this module can be ran with a minimal number of input variables in order to make generating several pipelines quickly a painless process. This module also creates the IAM resources necessary for the build/test stages of EC2 Image Builder to function properly.

## ⚠️ Notes

* Containers are not yet supported; functionality is planned!

* You MUST specify at least one component to be used in the EC2 image builder recipe. This can either be a custom component (via `var.imgb_components`) or a managed/shared component (via `var.imgb_aws_components`). For each custom component, only one of either the `data` or `uri` attributes may be entered.

* Component ordering is global across custom and managed component resources. When specifying the `order` attribute of a component, ensure order uniqueness across both `var.imgb_components` and `var.imgb_aws_components`.

* Component ordering *cannot* currently be changed between `terraform apply` runs due to the nature of Terraform dynamic blocks and the inability to force ordering of these. If you need to change the component order after creation, destroy then recreate the stack.

* When configuring AMI distribution (`imgdistcfg_distribution`) the `ami_dist_cfg` property *must* contain the AWS variable `{{imagebuilder:buildDate}}`.

## 🔍 Using This Module

The only *required* input variables to the module from your root module are:
* `imgb_stackname`
* `imgrep_parent_img`
* `imgb_components` or `imgb_aws_components`

By only providing the required input variables, this module will create an EC2 Image Builder pipeline with default settings and manual execution for the creation of an image with the given `imgrep_parent_img` as the base AMI, and then any given `imgb_components` or `imgb_aws_components` are applied on top of them.

### Examples

Refer to the `examples/` dir for basic and more involved examples.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_imagebuilder_component.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_component) | resource |
| [aws_imagebuilder_distribution_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration) | resource |
| [aws_imagebuilder_image.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image) | resource |
| [aws_imagebuilder_image_pipeline.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_pipeline) | resource |
| [aws_imagebuilder_image_recipe.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_recipe) | resource |
| [aws_imagebuilder_infrastructure_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_infrastructure_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_imgb_aws_components"></a> [imgb\_aws\_components](#input\_imgb\_aws\_components) | A map of objects with each object representing a pre-existing image builder component. To be used with managed AWS, shared, or other preexisting components you would like to reuse that aren't managed by this stack. | <pre>map(object({<br>    arn = string<br>    parameters = optional(list(object({<br>      name  = string<br>      value = list(string)<br>    })))<br>    order = optional(number)<br>  }))</pre> | `{}` | no |
| <a name="input_imgb_components"></a> [imgb\_components](#input\_imgb\_components) | A map of objects with each object representing an image builder component to create. If specifying the `data` attribute, this should be in the form of a relative path to the root module i.e. data/component1.yaml and is mutually exclusive with `uri`. | <pre>map(object({<br>    data                  = optional(string)<br>    uri                   = optional(string)<br>    platform              = string<br>    version               = string<br>    description           = optional(string)<br>    change_description    = optional(string)<br>    kms_key_id            = optional(string)<br>    supported_os_versions = optional(set(string))<br>    tags                  = optional(map(string))<br>    parameters = optional(list(object({<br>      name  = string<br>      value = list(string)<br>    })))<br>    order = optional(number)<br>  }))</pre> | `{}` | no |
| <a name="input_imgb_create_image_now"></a> [imgb\_create\_image\_now](#input\_imgb\_create\_image\_now) | WARNING significantly increased TF deployment times. A boolean to determine whether or not to create an image at the time of running Terraform in addition to any automated schedule configured. | `bool` | `false` | no |
| <a name="input_imgb_custom_iam_role"></a> [imgb\_custom\_iam\_role](#input\_imgb\_custom\_iam\_role) | A string representing the ARN of a custom IAM role to use in place of one created by this module. Leave default to use the module-created resource. | `string` | `""` | no |
| <a name="input_imgb_custom_instance_profile"></a> [imgb\_custom\_instance\_profile](#input\_imgb\_custom\_instance\_profile) | A string representing the ARN of a custom instance profile to use in place of one created by this module. Leave default to use the module-created resource. | `string` | `""` | no |
| <a name="input_imgb_custom_policy"></a> [imgb\_custom\_policy](#input\_imgb\_custom\_policy) | A string containing the full custom policy to apply to the role in addition to the managed policies. Leave default to forgo creation of the custom IAM policy resource. | `string` | `""` | no |
| <a name="input_imgb_image_timeout"></a> [imgb\_image\_timeout](#input\_imgb\_image\_timeout) | String representation of a duration i.e. 60m for 60 minutes or 2h for 2 hours, for Terraform to wait for the image to be built, tested, and distributed. | `string` | `null` | no |
| <a name="input_imgb_managed_policies"></a> [imgb\_managed\_policies](#input\_imgb\_managed\_policies) | A set of managed IAM policy ARNs to attach to the image builder instances. This should include EC2InstanceProfileForImageBuilder, EC2InstanceProfileForImageBuilderECRContainerBuilds, AmazonSSMManagedInstanceCore at a minimum. | `set(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder",<br>  "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds",<br>  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"<br>]</pre> | no |
| <a name="input_imgb_stackname"></a> [imgb\_stackname](#input\_imgb\_stackname) | The name for the image builder stack. This is used for naming the resources deployed by this module. | `string` | n/a | yes |
| <a name="input_imgdistcfg_description"></a> [imgdistcfg\_description](#input\_imgdistcfg\_description) | A description for the EC2 image builder distribution configuration. | `string` | `null` | no |
| <a name="input_imgdistcfg_distribution"></a> [imgdistcfg\_distribution](#input\_imgdistcfg\_distribution) | A list of AMI distribution configuration objects for the corresponding resource. Defaults to single-AMI output in same region. Custom AMI names MUST contain the AWS variable {{imagebuilder:buildDate}}. | <pre>list(object(<br>    {<br>      region                     = string<br>      license_configuration_arns = optional(set(string))<br>      ami_dist_cfg = optional(object({<br>        ami_tags           = optional(map(string))<br>        description        = optional(string)<br>        kms_key_id         = optional(string)<br>        name               = optional(string)<br>        target_account_ids = optional(set(string))<br>        launch_permission = optional(object({<br>          user_groups              = optional(set(string))<br>          user_ids                 = optional(set(string))<br>          organization_arns        = optional(set(string))<br>          organizational_unit_arns = optional(set(string))<br>        }))<br>      }))<br>      container_dist_cfg = optional(object({<br>        container_tags = optional(set(string))<br>        description    = optional(string)<br>        target_repo = object({<br>          repository_name = string<br>          service         = string<br>        })<br>      }))<br>      launch_template_cfg = optional(object({<br>        default            = optional(bool)<br>        launch_template_id = string<br>        account_id         = optional(string)<br>      }))<br>  }))</pre> | <pre>[<br>  {<br>    "ami_dist_cfg": {<br>      "name": "{{imagebuilder:buildDate}}"<br>    },<br>    "region": "us-east-1"<br>  }<br>]</pre> | no |
| <a name="input_imgdistcfg_kms_arn"></a> [imgdistcfg\_kms\_arn](#input\_imgdistcfg\_kms\_arn) | The ARN of a KMS key used to encrypt the distribution configuration. | `string` | `null` | no |
| <a name="input_imgdistcfg_license_config_arns"></a> [imgdistcfg\_license\_config\_arns](#input\_imgdistcfg\_license\_config\_arns) | A set of License Manager License Configuration ARNs for use with the image builder distribution configuration. | `set(string)` | `null` | no |
| <a name="input_imgdistcfg_tags"></a> [imgdistcfg\_tags](#input\_imgdistcfg\_tags) | A map of key-value pairs to override the default tags on the distribution configuration. | `map(string)` | `null` | no |
| <a name="input_imginfracfg_description"></a> [imginfracfg\_description](#input\_imginfracfg\_description) | A description for the EC2 image builder infrastructure configuration. | `string` | `null` | no |
| <a name="input_imginfracfg_instance_types"></a> [imginfracfg\_instance\_types](#input\_imginfracfg\_instance\_types) | A set of EC2 instance types to use for building the image. | `set(string)` | `null` | no |
| <a name="input_imginfracfg_keypair"></a> [imginfracfg\_keypair](#input\_imginfracfg\_keypair) | The name of an EC2 key pair in order to connect to image builder worker instances. Leave default for no key pairs - SSM Session Manager can still be used if available. | `string` | `null` | no |
| <a name="input_imginfracfg_logging"></a> [imginfracfg\_logging](#input\_imginfracfg\_logging) | A set of objects containing logging options for the infrastructure configuration. Leave default for no logging. | <pre>set(object({<br>    s3_logs = object({<br>      s3_bucket_name = string<br>      s3_key_prefix  = optional(string)<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_imginfracfg_sg_ids"></a> [imginfracfg\_sg\_ids](#input\_imginfracfg\_sg\_ids) | A set of EC2 security group identifiers to attach to image builder worker instances. Leave default to use the default security group. | `set(string)` | `null` | no |
| <a name="input_imginfracfg_sns_topic_arn"></a> [imginfracfg\_sns\_topic\_arn](#input\_imginfracfg\_sns\_topic\_arn) | The ARN of an SNS topic for the infrastructure configuration. | `string` | `null` | no |
| <a name="input_imginfracfg_subnet_id"></a> [imginfracfg\_subnet\_id](#input\_imginfracfg\_subnet\_id) | The EC2 subnet identifier to use during building and testing. WARNING You must also set imginfracfg\_sg\_ids so the instance has security groups attached. | `string` | `null` | no |
| <a name="input_imginfracfg_tags"></a> [imginfracfg\_tags](#input\_imginfracfg\_tags) | A map of key-value pairs to override the default tags on the infrastructure configuration. | `map(string)` | `null` | no |
| <a name="input_imginfracfg_term_on_fail"></a> [imginfracfg\_term\_on\_fail](#input\_imginfracfg\_term\_on\_fail) | Terminate EC2 instance on build failure - True will terminate on failure and False will retain the instance. Defaults to True. | `bool` | `true` | no |
| <a name="input_imgpipe_EIM_enabled"></a> [imgpipe\_EIM\_enabled](#input\_imgpipe\_EIM\_enabled) | Enable or disable Enhanced Image Metadata. | `bool` | `true` | no |
| <a name="input_imgpipe_description"></a> [imgpipe\_description](#input\_imgpipe\_description) | A description for the EC2 image builder pipeline. | `string` | `null` | no |
| <a name="input_imgpipe_schedule"></a> [imgpipe\_schedule](#input\_imgpipe\_schedule) | The cron schedule, timezone, and pipeline execution start condition object. Leave default for manual running of the pipeline. Default timezone parameter = UTC | <pre>set(object({<br>    schedule_expression                = string<br>    pipeline_execution_start_condition = optional(string)<br>    timezone                           = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_imgpipe_status"></a> [imgpipe\_status](#input\_imgpipe\_status) | Enable or disable the image builder pipeline. | `string` | `"ENABLED"` | no |
| <a name="input_imgpipe_tags"></a> [imgpipe\_tags](#input\_imgpipe\_tags) | A map of key-value pairs to override the default tags on the image pipeline. | `map(string)` | `null` | no |
| <a name="input_imgpipe_tests_enabled"></a> [imgpipe\_tests\_enabled](#input\_imgpipe\_tests\_enabled) | Enable or disable image tests. True will enable tests, False will disable tests. | `bool` | `true` | no |
| <a name="input_imgpipe_timeout_mins"></a> [imgpipe\_timeout\_mins](#input\_imgpipe\_timeout\_mins) | The maximum threshold in minutes for the image testing to timeout and fail. Must be between 60 and 1440 (1 and 24 hours). | `number` | `720` | no |
| <a name="input_imgrep_block_device_maps"></a> [imgrep\_block\_device\_maps](#input\_imgrep\_block\_device\_maps) | A list of block device mappings to apply when creating images. Defaults to no additional block devices. | <pre>list(object({<br>    device_name  = optional(string)<br>    no_device    = optional(string)<br>    virtual_name = optional(string)<br>    ebs = object({<br>      delete_on_termination = optional(bool)<br>      encrypted             = optional(bool)<br>      iops                  = optional(number)<br>      kms_key_id            = optional(string)<br>      snapshot_id           = optional(string)<br>      throughput            = optional(number)<br>      volume_size           = optional(number)<br>      volume_type           = optional(string)<br>    })<br>  }))</pre> | `null` | no |
| <a name="input_imgrep_description"></a> [imgrep\_description](#input\_imgrep\_description) | Enter a description for the image recipe. | `string` | `null` | no |
| <a name="input_imgrep_parent_img"></a> [imgrep\_parent\_img](#input\_imgrep\_parent\_img) | The parent image of this image recipe; either the ARN of the base image or an AMI ID. Version in the image ARN can be included or wildcarded. | `string` | n/a | yes |
| <a name="input_imgrep_sysmanager_uninstall"></a> [imgrep\_sysmanager\_uninstall](#input\_imgrep\_sysmanager\_uninstall) | Whether to remove the Systems Manager Agent after the image has been built. | `bool` | `false` | no |
| <a name="input_imgrep_tags"></a> [imgrep\_tags](#input\_imgrep\_tags) | A map of key-value pairs to override the default tags on the image recipe. | `map(string)` | `null` | no |
| <a name="input_imgrep_user_data"></a> [imgrep\_user\_data](#input\_imgrep\_user\_data) | Base64-encoded user data to provide commands when launching your build instance. | `string` | `null` | no |
| <a name="input_imgrep_version"></a> [imgrep\_version](#input\_imgrep\_version) | The semantic version of the image recipe. Defaults to 1.0.0 but any suitable semantic version is accepted. | `string` | `"1.0.0"` | no |
| <a name="input_imgrep_working_dir"></a> [imgrep\_working\_dir](#input\_imgrep\_working\_dir) | The working directory to use for build and test workflows. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to create the resources from this module. | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_builder_info"></a> [builder\_info](#output\_builder\_info) | n/a |
| <a name="output_component_info"></a> [component\_info](#output\_component\_info) | n/a |
| <a name="output_distribution_info"></a> [distribution\_info](#output\_distribution\_info) | n/a |
| <a name="output_image_info"></a> [image\_info](#output\_image\_info) | n/a |
| <a name="output_pipeline_info"></a> [pipeline\_info](#output\_pipeline\_info) | n/a |
<!-- END_TF_DOCS -->