locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  dns_suffix = data.aws_partition.current.dns_suffix
  aliases    = { for k, v in toset(var.aliases) : k => { name = v } }
  tags       = merge({ "ManagedBy" = "Terraform" }, var.tags)
}