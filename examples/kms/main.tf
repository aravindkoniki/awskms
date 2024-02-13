provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

# KMS Key
module "kms" {
  source                = "../../module"
  key_name              = "test/${var.key_name}"
  description           = "${var.key_name} cluster encryption key"
  key_usage             = "ENCRYPT_DECRYPT"
  enable_default_policy = false
  key_administrators    = [data.aws_caller_identity.current.arn]
  computed_aliases = {
    cluster = { name = "test/${var.key_name}" }
  }
  tags = var.tags
}