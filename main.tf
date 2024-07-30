######################################################
#### COPY & PASTE THIS FILE INTO YOUR REPOSITORY  ####
######################################################

######################################################
#### START - ADD YOUR CUSTOM INFRASTRUCTURE HERE  ####
######################################################


# User Input: Enter state machine module name
module "[ENTER_STATE_MACHINE_MODULE_NAME]-statemachine" {
  source = "./statemachine"

  env             = var.env
  region          = var.region
  repository_name = var.repository_name
}

# User Input: Enter lambda module name
module "[ENTER_LAMBDA_MODULE_NAME]-lambda" {
  source = "./lambda"

  env             = var.env
  region          = var.region
  repository_name = var.repository_name
}

# User Input: Enter S3 module name
module "[ENTER_S3_MODULE_NAME]-s3" {
  source = "./s3"

  env = var.env
}
######################################
#### END - CUSTOM INFRASTRUCTURE  ####
######################################

######################################################
#### START - REQUIRED IN TEMPLATE - DO NOT ALTER  ####
######################################################
# Note. This must be at the root of any repository which is deploying serverless code
variable "env" {
  description = "env: dev, staging or prod"
  default     = "dev"
  validation {
    condition = contains([
      "dev",
      "staging",
      "prod",
      "fda-dev",
      "fda-prod",
    "pre-prod"], var.env)
    error_message = "Allowed values for env are 'dev', 'staging', 'fda-dev', 'fda-prod', 'pre-prod', or 'prod'."
  }
}

variable "profile" {
  type        = string
  description = "The AWS profile which these resources are deployed under"
  default     = ""
}

variable "region" {
  type        = string
  description = "The AWS profile which these resources are deployed under"
  default     = "us-gov-west-1"
}

variable "repository_name" {
  type        = string
  description = "The name of this repository on GitHub or GitLab"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}


data "aws_ssm_parameter" "github_token" {
  name = "/mde/GITHUB_CODEPIPELINE_ACCESS_TOKEN"
}

provider "github" {
  token = data.aws_ssm_parameter.github_token.value
  owner = "icaglobal"
}

terraform {
  backend "s3" {
    bucket         = "mde-tfstate-pre-prod"
    dynamodb_table = "mde-terraform-lock"
    key            = "terraform.tfstate"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}
#####################################
#### END - REQUIRED IN TEMPLATE  ####
#####################################
