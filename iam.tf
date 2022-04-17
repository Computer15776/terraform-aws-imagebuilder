# Default IAM instance profile to use with imagebuilder
resource "aws_iam_instance_profile" "main" {
  count = var.imgb_custom_instance_profile == "" ? 1 : 0
  name  = "${var.imgb_stackname}-imagebuilder-profile"
  role  = aws_iam_role.main[0].name
}

# Default IAM role to use with imagebuilder
resource "aws_iam_role" "main" {
  count = var.imgb_custom_iam_role == "" ? 1 : 0
  name  = "${var.imgb_stackname}-imagebuilder-role"
  path  = "/"

  assume_role_policy  = file("${path.root}/policies/iam/iam_assume_role.json")
  managed_policy_arns = var.imgb_managed_policies
}

# Additional S3logs policy if logging is needed
resource "aws_iam_policy" "s3logs" {
  for_each = local.s3_buckets # Only create policy if there are S3 logging buckets that need the addtl permissions

  name        = "${var.imgb_stackname}-imagebuilder-s3logs"
  path        = "/"
  description = "Allow the EC2 Image Builder infrastructure to access the S3 bucket for logging purposes"
  policy      = templatefile("${path.module}/policies/iam/s3logs.json", { s3_buckets = jsonencode(local.s3_buckets) })
}

resource "aws_iam_role_policy_attachment" "s3logs" {
  for_each = aws_iam_policy.s3logs

  role       = aws_iam_role.main[0].name
  policy_arn = aws_iam_policy.s3logs[each.key].arn
}

# Additional custom policy if extra user-specified permissions are needed
resource "aws_iam_policy" "custom" {
  count = var.imgb_custom_policy != "" ? 1 : 0

  name        = "${var.imgb_stackname}-imagebuilder-custom"
  path        = "/"
  description = "Allow the EC2 Image Builder infrastructure to use a policy with custom access"
  policy      = var.imgb_custom_policy
}

resource "aws_iam_role_policy_attachment" "custom" {
  count = var.imgb_custom_policy != "" ? 1 : 0

  role       = aws_iam_role.main[0].name
  policy_arn = aws_iam_policy.custom[0].arn
}

