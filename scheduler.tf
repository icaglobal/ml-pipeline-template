variable "pipeline_name" {
  type        = string
  description = "The name of this pipeline"

  # User Input: Enter the name of the pipeline
  default = "mde-[ENTER_PIPELINE_NAME]"
}

# runs daily 3am
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.pipeline_name}-weekly-run"
  description         = "Schedule for ${var.pipeline_name}-invoke Lambda Function"

  # User Input: Enter the CRON expression for when the pipeline should be run
  schedule_expression = "[ENTER_CRON_EXPRESSION]"
}

resource "aws_cloudwatch_event_target" "schedule_lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "inference_lambdas"
  arn       = "arn:${data.aws_partition.current.partition}:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.pipeline_name}-invoke-${var.env}-mde"

  # User Input: Enter the JSON input for the Lambda function here
  input = jsonencode({
  "SAMPLE_INSTANCE" : "ml.c5.2xlarge",
  "REGION" : "us-gov-west-1",
  "ENV_NAME": "pre-prod",
  })

  depends_on = [
    aws_cloudwatch_event_rule.schedule,
    aws_lambda_permission.allow_events_bridge_to_run_lambda
  ]

}

resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${var.pipeline_name}-invoke-${var.env}-mde"
  principal     = "events.amazonaws.com"
}
