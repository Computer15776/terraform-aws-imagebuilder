module "image_pipeline" {
  source  = "Computer15776/imagebuilder/aws"
  version = "~> 0.1.2"

  imgb_stackname    = "mysecondimage"         # Applied as a prefix to module-created resources
  imgrep_parent_img = "ami-083654bd07b5da81d" # Base AMI; Ubuntu 20.04 LTS x86, us-east-1
  imgb_aws_components = {
    cw-agent = {
      arn   = "arn:aws:imagebuilder:us-east-1:aws:component/amazon-cloudwatch-agent-linux/1.0.0/1" # An ARN of a pre-existing component managed by AWS in us-east-1
      order = 1                                                                                    # The order that components will be built and tested in
    }
  }
  imgb_components = {
    mycustomcomponent = {                        # Key represents the component name
      platform = "Linux"                         # The base platform this component runs from
      version  = "1.0.0"                         # The version of this component
      data     = "policies/imgbuilder/test.yaml" # A relative path from the root module to an AWSTOE YAML document defining component functionality
      order    = 2                               # The order that components will be built and tested in. This component runs after cw-agent.
    }
  }
  imgpipe_schedule = [
    {
      schedule_expression                = "cron(0 0 * * ? *)"     # Runs the pipeline daily at midnight
      pipeline_execution_start_condition = "EXPRESSION_MATCH_ONLY" # Will trigger each time cron runs
    }
  ]
  imgb_create_image_now = true
}
