########################################################################################
#### COPY & PASTE THIS FILE INTO ANY SUBDIRECTORIES CONTAINING *.TF STATE MACHINES  ####
########################################################################################

##################################
#### START - CUSTOM TEMPLATE  ####
##################################

# User Input: Enter the module name here
module "[ENTER_MODULE_NAME]" {
  source = "git@mde:icaglobal/MDE-infrastructure.git//serverless-cicd/predefined_workflows/batch_transform?ref=v1.9.5"

  region          = var.region
  repository_name = var.repository_name
  env             = var.env
  skip_cicd       = true

  # User Input: Enter the name here
  name = "[ENTER_NAME]"

  state_machine_data = {
    definition = "./statemachine/state-machine-definition.json"
  }


  sns_status_notifications = true
  sns_notification_emails  = var.notification_emails

}
##############################################
#### END - CUSTOM STATE MACHINE TEMPLATE  ####
##############################################

######################################################################
#### START - REQUIRED IN TEMPLATE OF SUBDIRECTORY - DO NOT ALTER  ####
######################################################################
# Note. This must be copied/pasted into any subdirectories containing .tf files defining resources which is to be deployed into the MDE environment
variable "env" {
  description = "env: dev, staging or prod"
  default     = "dev"
  validation {
    condition = contains([
      "dev",
      "staging",
      "prod",
      "fda-dev",
      "prod",
    "pre-prod"], var.env)
    error_message = "Allowed values for env are 'dev', 'staging', 'fda-dev', 'fda-prod', 'pre-prod', or 'prod'."
  }
}

variable "repository_name" {
  type        = string
  description = "The name of this repository on GitHub or GitLab"
}
#####################################################
#### END - REQUIRED IN TEMPLATE OF SUBDIRECTORY  ####
#####################################################
