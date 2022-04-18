module "image_pipeline" {
  source  = "Computer15776/imagebuilder/aws"
  version = "~> 0.1.2"
  imgb_stackname    = "myfirstimage"          # Applied as a prefix to module-created resources
  imgrep_parent_img = "ami-083654bd07b5da81d" # Base AMI; Ubuntu 20.04 LTS x86, us-east-1
  imgb_aws_components = {
    cw-agent = {
      arn   = "arn:aws:imagebuilder:us-east-1:aws:component/amazon-cloudwatch-agent-linux/1.0.0/1" # An ARN of a pre-existing component managed by AWS in us-east-1
      order = 1                                                                                    # The order that components will be built and tested in
    }
  }
}
