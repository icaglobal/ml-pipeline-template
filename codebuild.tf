variable "project_name" {
  description = "project name for cloud build"
  type        = string

  # User Input: Enter the name of the project
  default = "[ENTER_PROJECT_NAME]"
}

# CodeBuild module
# User Input: Enter CodeBuild module name
module "[ENTER_MODULE_NAME]-codebuild" {
  source = "git@mde:icaglobal/MDE-infrastructure.git//codebuild_ecr?ref=v1.12.5"

  env            = var.env
  region         = var.region
  project_name   = var.project_name
  buildspec_file = "./buildspec.yml"

  ecr_repo_name = local.ecr_repo_name

  project_description = "CodeBuild project for building Docker image for ${var.project_name}"

  # User Input: Specify the directories or files whose modification should retrigger CodeBuild
  # Example: ["./src/", "./docs/", "./scripts/build.sh"]
  dependent_files = concat(
    # User Input: Specify the first directory or file to watch for changes
    [for file in fileset("[ENTER_FIRST_SOURCE_DIRECTORY_OR_FILE]", "**") : format("%s%s", "[ENTER_FIRST_SOURCE_DIRECTORY_OR_FILE]", file)],
    # User Input: Specify the second directory or file to watch for changes (or remove or add more)
    [for file in fileset("[ENTER_SECOND_SOURCE_DIRECTORY_OR_FILE]", "**") : format("%s%s", "[ENTER_SECOND_SOURCE_DIRECTORY_OR_FILE]", file)],
    # Add any additional specific files you want to watch for changes
    ["./requirements.txt"]
    # Add more files as needed
  )
}
