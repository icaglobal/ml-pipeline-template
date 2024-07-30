data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  # User Input: Enter state machine name
  statemachine_arn = "arn:${data.aws_partition.current.partition}:states:${var.region}:${local.aws_account_id}:stateMachine:[ENTER_STATE_MACHINE_NAME]-${var.env}-mde"

  # User Input: Enter ECR repository name
  ecr_repo_name = lower("mde-[ENTER_REPOSITORY_NAME]-${var.env}")
}
