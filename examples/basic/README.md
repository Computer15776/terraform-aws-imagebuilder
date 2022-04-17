## Minimal implementation, manual schedule
```
imgb_stackname    = "myfirstimage" # Applied as a prefix to module-created resources
imgrep_parent_img = "ami-083654bd07b5da81d" # Base AMI; Ubuntu 20.04 LTS x86, us-east-1
imgb_aws_components = {
  cw-agent = {
    arn   = "arn:aws:imagebuilder:us-east-1:aws:component/amazon-cloudwatch-agent-linux/1.0.0/1" # An ARN of a pre-existing component managed by AWS in us-east-1
    order = 1 # The order that components will be built and tested in
  }
}
```
**Result** - A number of EC2 Image Builder resources prefixed with `myfirstimage` are provisioned in the us-east-1 region. The resulting image recipe resource created uses a base AMI of Ubuntu 20.04 LTS in the same region, and when the EC2 Image Builder pipeline is manually triggered it will build from this AMI and subsequently apply the `cw-agent` component. This is an AWS-managed component already live in us-east-1 and when the pipeline is executed the Amazon CloudWatch Agent will be installed. Since it has an `order` of 1, it would also be the first component to be executed, should any additional components be introduced.