# ML Pipeline Template

This repository provides a template for creating a machine learning pipeline using AWS services. The template includes configurations for Lambda functions, S3, CodeBuild, ECR, Docker, and State Machines.

The typical paradigm is to have Jenkins monitor for pushes to the GitLab repository. When a GitLab push occurs, the FDA Jeknins server executes a `terraform apply` command which provisions the infrastructure detailed in the repository. It ensures the Lambda triggering function and state machines are provisioned, in addition to triggering CodeBuild to rebuild the Docker image and upload that to ECR, provide there was a change to the source code. There is also a scheduler which automates pipeline runs in the cloud.

## Directory Structure

- **lambda/**: Contains Lambda function code.
  - **international_data_invoke/**: Example Lambda function directory.
    - `lambda_function.py`: Example Python script for the Lambda function.
    - `main.tf`: Terraform file for deploying the Lambda function.

- **s3/**: Contains configurations for S3 buckets.
  - `main.tf`: Terraform file for setting up S3 buckets.

- **statemachine/**: Contains configurations for AWS Step Functions.
  - `state-machine-definition.json`: Example JSON configuration for a state machine. Customize this file based on your workflow.
  - `README.md`: Guidance for configuring the state machine.
  - `main.tf`: Terraform file for deploying the state machine.
  - `variable.tf`: Terraform variables for the state machine.

- `.gitignore`: Specifies files and directories to be ignored by git.
- `Dockerfile`: Defines the Docker image for the project.
- `README.md`: This file.
- `codebuild.tf`: Terraform file for setting up AWS CodeBuild.
- `locals.tf`: Local variables for Terraform.
- `main.tf`: Main Terraform file for setting up the infrastructure.
- `scheduler.tf`: Terraform file for setting up scheduled tasks.
- `terraform.tfvars`: Contains variable definitions for Terraform.
- `requirements.txt`: Python dependencies for the Lambda functions.
- `buildspec.yml`: Build specification for AWS CodeBuild.

## User Input Fields in Terraform Configuration

### Identifying User Input Fields

User input fields in the Terraform files are clearly marked to help you easily locate and update them. Here's how you can identify them:

1. **Comments Above Fields**: Fields requiring user input are preceded by a comment starting with `# User Input:`.
2. **Placeholders**: Fields that need your input contain placeholders in the format `[ENTER_...]`.

### Example Customization

#### codebuild.tf

```terraform
variable "project_name" {
  description = "project name for cloud build"
  type        = string

  # User Input: Enter the name of the project
  default = "[ENTER_PROJECT_NAME]"
}

# CodeBuild module
module "codebuild" {
  source = "git@mde:icaglobal/MDE-infrastructure.git//codebuild_ecr?ref=v1.12.5"

  env            = var.env
  region         = var.region
  project_name   = var.project_name
  buildspec_file = "./buildspec.yml"

  ecr_repo_name = local.ecr_repo_name

  project_description = "CodeBuild project for building Docker image for ${var.project_name}"

  # User Input: Specify the directories or files whose modification should retrigger CodeBuild
  dependent_files = concat(
    # Specify the first directory or file to watch for changes
    [for file in fileset("[ENTER_FIRST_SOURCE_DIRECTORY_OR_FILE]", "**") : format("%s%s", "[ENTER_FIRST_SOURCE_DIRECTORY_OR_FILE]", file)],
    # Specify the second directory or file to watch for changes (or add more)
    [for file in fileset("[ENTER_SECOND_SOURCE_DIRECTORY_OR_FILE]", "**") : format("%s%s", "[ENTER_SECOND_SOURCE_DIRECTORY_OR_FILE]", file)],
    # Add any additional specific files you want to watch for changes
    ["./requirements.txt", ...] # Add more files as needed
  )
}
```

### How to Provide User Inputs

1. **Locate the User Input Fields**:
   - Search for comments starting with `# User Input:` to find mandatory fields.
   - Look for placeholders in the format `[ENTER_...]` to find the fields requiring your input.

2. **Replace Placeholders**:
   - Replace the placeholder text with the appropriate values for your deployment.

## Using AWS State Machine Editor

To simplify the design and modification process for state machines, use the "Edit" functionality available in AWS Step Functions:

1. **Design in GUI**: Use the graphical interface provided by AWS to design your state machine.
2. **Export Configuration**: After designing, export the configuration as a JSON file and save it as `state-machine-definition.json` in the `statemachine/` directory.

By following this paradigm, you ensure that all necessary fields are properly configured for your deployment. If you have any questions or need further assistance, please refer to the project documentation or contact the project maintainers.
