variable "notification_emails" {
  type        = list(string)
  description = "Emails to notify"
  default = ["kishan.patel@fda.hhs.gov", "timothy.tucker@fda.hhs.gov", "taran.grove@fda.hhs.gov",
    "kolawole.oseni@fda.hhs.gov",
    "francis.hackenburg@fda.hhs.gov"]
}

variable "region" {
  type        = string
  description = "The AWS profile which these resources are deployed under"
  default     = ""
}

variable "skip_cicd" {
  type        = bool
  description = "Whether or not we should skip the creation of the CI/CD infrastructure"
  default     = false
}
