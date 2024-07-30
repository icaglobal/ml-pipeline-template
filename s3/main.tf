# User Input: Enter name of S3 bucket resource
resource "aws_s3_bucket" "[ENTER_BUCKET_RESOURCE_NAME]" {

  # User Input: Enter the initial part of the bucket name here
  bucket = "[ENTER_BUCKET_NAME]-${var.env}"
}

variable "env" {
  description = "env: dev, staging or prod"
  default     = "dev"
  validation {
    condition = contains([
      "dev",
      "staging",
      "prod",
      "fda-dev",
    "pre-prod"], var.env)
    error_message = "Allowed values for env are 'dev', 'staging', 'fda-dev', 'fda-prod', 'pre-prod', or 'prod'."
  }
}

variable "region" {
  type        = string
  description = "The AWS profile which these resources are deployed under"
  default     = ""
}
