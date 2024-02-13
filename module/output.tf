output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = try(aws_kms_key.primary_key[0].arn, aws_kms_external_key.external_key[0].arn, aws_kms_replica_key.replica_key[0].arn, aws_kms_replica_external_key.external_replica_key[0].arn, null)
}

output "key_id" {
  description = "The globally unique identifier for the key"
  value       = try(aws_kms_key.primary_key[0].key_id, aws_kms_external_key.external_key[0].id, aws_kms_replica_key.replica_key[0].key_id, aws_kms_replica_external_key.external_replica_key[0].key_id, null)
}

output "key_policy" {
  description = "The IAM resource policy set on the key"
  value       = try(aws_kms_key.primary_key[0].policy, aws_kms_external_key.external_key[0].policy, aws_kms_replica_key.replica_key[0].policy, aws_kms_replica_external_key.external_replica_key[0].policy, null)
}

output "external_key_expiration_model" {
  description = "Whether the key material expires. Empty when pending key material import, otherwise `KEY_MATERIAL_EXPIRES` or `KEY_MATERIAL_DOES_NOT_EXPIRE`"
  value       = try(aws_kms_external_key.external_key[0].expiration_model, aws_kms_replica_external_key.external_replica_key[0].expiration_model, null)
}

output "external_key_state" {
  description = "The state of the CMK"
  value       = try(aws_kms_external_key.external_key[0].key_state, aws_kms_replica_external_key.external_replica_key[0].key_state, null)
}

output "external_key_usage" {
  description = "The cryptographic operations for which you can use the CMK"
  value       = try(aws_kms_external_key.external_key[0].key_usage, aws_kms_replica_external_key.external_replica_key[0].key_usage, null)
}

output "aliases" {
  description = "A map of aliases created and their attributes"
  value       = aws_kms_alias.kms_alias
}

output "grants" {
  description = "A map of grants created and their attributes"
  value       = aws_kms_grant.kms_grant
}