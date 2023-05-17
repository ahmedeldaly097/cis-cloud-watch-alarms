variable "account_name" {
  type        = string
  description = "Name of the account"
}

variable "resource_type" {
  type        = list(string)
  description = "Name of the resource type relevant to the alarm"
  default     = ["securitygroup", "networkacl", "igw", "routetable", "vpc", "cloudtrail", "iampolicy", "cmk", "s3policy", "awsconfig"]
}

variable "metric_filter" {
  type        = list(string)
  description = "Syntax of metric filter"
}
