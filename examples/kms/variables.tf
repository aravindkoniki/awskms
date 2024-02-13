variable "region" {
  type        = string
  description = "Region for the resource to deploy"
}

variable "key_name" {
  description = "Name of the KMS key"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}