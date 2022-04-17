## Multi-component implementation, automated schedule
```
imgb_stackname    = "mysecondimage" # Applied as a prefix to module-created resources
imgrep_parent_img = "ami-083654bd07b5da81d" # Base AMI; Ubuntu 20.04 LTS x86, us-east-1
imgb_aws_components = {
  cw-agent = {
    arn   = "arn:aws:imagebuilder:us-east-1:aws:component/amazon-cloudwatch-agent-linux/1.0.0/1" # An ARN of a pre-existing component managed by AWS in us-east-1
    order = 1 # The order that components will be built and tested in
  }
}
imgb_components = {
  mycustomcomponent = { # Key represents the component name
    platform = "Linux" # The base platform this component runs from
    version  = "1.0.0" # The version of this component
    data     = "policies/imgbuilder/test.yaml" # A relative path from the root module to an AWSTOE YAML document defining component functionality
    order    = 2 # The order that components will be built and tested in. This component runs after cw-agent.
  }
}
imgpipe_schedule = [
  {
    schedule_expression = "cron(0 0 * * ? *)" # Runs the pipeline daily at midnight
    pipeline_execution_start_condition = "EXPRESSION_MATCH_ONLY" # Will trigger each time cron runs
  }
]
imgb_create_image_now = true
```
**Result** - A number of EC2 Image Builder resources prefixed with `mysecondimage` are provisioned in the us-east-1 region. The resulting image recipe resource created uses a base AMI of Ubuntu 20.04 LTS in the same region, and when the EC2 Image Builder pipeline is automatically triggered via its daily midnight cron schedule it will build from this AMI and subsequently apply the `cw-agent` component. Since it has an `order` of 1, it would also be the first component to be executed, should any additional components be introduced. However, a custom component named `mycustomcomponent` is now also defined. It contains a data attribute referencing an [AWSTOE YAML document](https://docs.aws.amazon.com/imagebuilder/latest/userguide/toe-use-documents.html) which is used to define component behaviour. In this instance, it executes a simple "hello world" echo command. Note that `order` must be globally unique and so cannot equal `1` again as this is already taken by the managed `cw-agent` component. Since `mycustomcomponent` has an order of 2, it will run _after_ `cw-agent`.

The pipeline schedule is set to run at the defined expression, with a start condition of `EXPRESSION_MATCH_ONLY`. The only other alternative start condition is `EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE`, which will only bake a new AMI when the cron runs if the semver of any associated components you are using changes.

Lastly, `imgb_create_image_now` is set to `true` which means Terraform will also instantly begin creating an image via the configuration in addition to the set cron schedule. NB enabling this boolean var will mean that Terraform must wait for tens of minutes for the image to be built, tested, and then distributed (if applicable).