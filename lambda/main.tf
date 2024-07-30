#####################################################################################################
#### COPY & PASTE THIS FILE INTO ANY SUBDIRECTORIES CONTAINING *.TF LAMBDA FUNCTIONS REPOSITORY  ####
#####################################################################################################

##################################################
#### START - CUSTOM LAMBDA FUNCTION TEMPLATE  ####
##################################################

##### Define Functions Here

# User Input: Provide the module name below
module "[ENTER_MODULE_NAME]" {

  # DO NOT CHANGE THE FOLLOWING ATTRIBUTES
  source = "git@mde:icaglobal/MDE-infrastructure.git//serverless-cicd/lambda?ref=v1.10.61"
  env    = var.env
  # Will default to dev. Options are 'dev', 'staging', and 'prod'
  repository_name = var.repository_name
  region          = var.region
  skip_cicd       = true

  # User Input: Provide a unique name to identify infrastructure deployed from this module
  name = "[ENTER_NAME]"

  functions = [
    {
      # User Input: Provide the function name
      function_name = "mde-[ENTER_FUNCTION_NAME]-invoke"
      handler       = "lambda_function.lambda_handler"
      runtime       = "python3.9"

      # User Input: Provide a description for the function
      description = "Kicks off [ENTER_PROJECT_NAME] Pipeline"

      # Optional User Input: Enter timeout
      timeout = 60

      # Option User Input: Enter memory size
      memory_size = 128

      docker_lambda_enabled = false
      security_group_ids    = []
      destinations = [
        {
          type : "SNS"
          // (Could be SNS, SQS, or S3)
          name : "pipeline-topic-test"
          // (sns topic name - I think)
          condition : "failure"
          // ("success" or "failure")
        }
      ]
    }
  ]

  ###################################################
  ############### Optional Attributes ###############
  ###################################################

  resources = { # Specify any additional resources which should be defined for this module to be used as destinations or triggers
    topics = [
      {
        topic_name = "pipeline-topic-test"    # Required. The name of the topic which should trigger this lambda function
        import     = false                    # Optional. Will default to false. If false, on deploy we will create a new topic under the topic_name. If this is set to true, it will import an existing topic from our environment (or throw an error if an existing topic does not exist)
        options = {                           # Optional. Provide additional configuration to the SNS topic. Default is null
          fifo_topic                  = false # Optional Boolean indicating whether or not to create a FIFO (first-in-first-out) topic (default is false)
          content_based_deduplication = false # Optional Enables content-based deduplication for FIFO topics
        }
      }
    ]
  }

  build_file    = "./lambda/buildspec.yml" # Will default to './buildspec.yml'. Path to the AWS CodeBuild buildspec file
  build_env     = {}                       # Will default to empty map. Map of environment variables that are accessible during builds. The key represents the name of the env variable, and the value represents the value of the variable.
  build_secrets = {}                       # Will default to empty map. Map of secrets (from SSM Parameter Store) that are accessible during builds. The key represents the name of the env variable, and the value represents the path of that variable in Parameter Store.

  source_dir = "./lambda/lambda_invoke" # Will default to './'. Note the path is relative to the root of this repository (aka where the root main.tf file is located)

  exclude_files = [
    "buildspec.yml",
    "main.tf",
    "README.md"
  ] # Defaults to []. Any files which should not be deployed with this function. Should be relative to the source_dir. Does not support file globs.

  # Optional User Input: Set the build timeout value
  build_timeout = 15
}


################################################
#### END - CUSTOM LAMBDA FUNCTION TEMPLATE  ####
################################################



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
    "pre-prod"], var.env)
    error_message = "Allowed values for env are 'dev', 'staging', or 'prod'."
  }
}

variable "repository_name" {
  type        = string
  description = "The name of this repository on GitHub or GitLab"
}

variable "region" {
  type        = string
  description = "The AWS profile which these resources are deployed under"
  default     = ""
}
#####################################################
#### END - REQUIRED IN TEMPLATE OF SUBDIRECTORY  ####
#####################################################
