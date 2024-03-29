resource "aws_kms_key" "primary_key" {
  count                              = !var.create_external && !var.create_replica && !var.create_replica_external ? 1 : 0
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  customer_master_key_spec           = var.customer_master_key_spec
  custom_key_store_id                = var.custom_key_store_id
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  enable_key_rotation                = var.enable_key_rotation
  is_enabled                         = var.is_enabled
  key_usage                          = var.key_usage
  multi_region                       = var.multi_region
  policy                             = coalesce(var.policy, data.aws_iam_policy_document.kms_policy.json)
  tags                               = merge({ "Name" = var.key_name }, local.tags)
}

resource "aws_kms_external_key" "external_key" {
  count                              = var.create_external && !var.create_replica && !var.create_replica_external ? 1 : 0
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  enabled                            = var.is_enabled
  key_material_base64                = var.key_material_base64
  multi_region                       = var.multi_region
  policy                             = coalesce(var.policy, data.aws_iam_policy_document.kms_policy.json)
  valid_to                           = var.valid_to
  tags                               = merge({ "Name" = var.key_name }, local.tags)
}

resource "aws_kms_replica_key" "replica_key" {
  count                              = var.create_replica && !var.create_external && !var.create_replica_external ? 1 : 0
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  primary_key_arn                    = var.primary_key_arn
  enabled                            = var.is_enabled
  policy                             = coalesce(var.policy, data.aws_iam_policy_document.kms_policy.json)
  tags                               = merge({ "Name" = var.key_name }, local.tags)
}

resource "aws_kms_replica_external_key" "external_replica_key" {
  count                              = !var.create_replica && !var.create_external && var.create_replica_external ? 1 : 0
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  enabled                            = var.is_enabled
  key_material_base64                = var.key_material_base64
  policy                             = coalesce(var.policy, data.aws_iam_policy_document.kms_policy.json)
  primary_key_arn                    = var.primary_external_key_arn
  valid_to                           = var.valid_to
  tags                               = merge({ "Name" = var.key_name }, local.tags)
}

resource "aws_kms_alias" "kms_alias" {
  for_each      = { for k, v in merge(local.aliases, var.computed_aliases) : k => v }
  name          = var.aliases_use_name_prefix ? null : "alias/${each.value.name}"
  name_prefix   = var.aliases_use_name_prefix ? "alias/${each.value.name}-" : null
  target_key_id = try(aws_kms_key.primary_key[0].key_id, aws_kms_external_key.external_key[0].id, aws_kms_replica_key.replica_key[0].key_id, aws_kms_replica_external_key.external_replica_key[0].key_id)
}

resource "aws_kms_grant" "kms_grant" {
  for_each          = { for k, v in var.grants : k => v }
  name              = try(each.value.name, each.key)
  key_id            = try(aws_kms_key.primary_key[0].key_id, aws_kms_external_key.external_key[0].id, aws_kms_replica_key.replica_key[0].key_id, aws_kms_replica_external_key.external_replica_key[0].key_id)
  grantee_principal = each.value.grantee_principal
  operations        = each.value.operations

  dynamic "constraints" {
    for_each = length(lookup(each.value, "constraints", {})) == 0 ? [] : [each.value.constraints]

    content {
      encryption_context_equals = try(constraints.value.encryption_context_equals, null)
      encryption_context_subset = try(constraints.value.encryption_context_subset, null)
    }
  }

  retiring_principal    = try(each.value.retiring_principal, null)
  grant_creation_tokens = try(each.value.grant_creation_tokens, null)
  retire_on_delete      = try(each.value.retire_on_delete, null)
}