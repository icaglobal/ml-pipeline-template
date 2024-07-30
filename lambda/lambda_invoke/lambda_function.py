"""
There are two locations where information must be specified below:
    Project Name; and Processing Job Name(s).

Both have comments indicating where to enter the information.
"""

import json
import os
import uuid
from datetime import datetime, timedelta
import time

import boto3

# User Input: Enter project name here
PROJECT_NAME = "[ENTER_PROJECT_NAME]"


def lambda_handler(event, context):
    """
    Lambda to start stepfunction with sample inputs:
    DELETE COMMENTS WHEN RUNNING ON LAMBDA
    {
    "SAMPLE_INSTANCE" : "ml.c5.2xlarge",
    "REGION": "us-gov-west-1",
    "ENV_NAME": "pre-prod",
    """

    # get account id
    account_id = boto3.client("sts").get_caller_identity()["Account"]
    environment = os.environ.get("ENV")
    # REGION = os.environ.get("REGION")
    if environment not in [
        "dev",
        "staging",
        "prod",
        "fda-dev",
        "pre-prod",
    ]:
        print(
            "lambda ENV variable not set properly or missing: should be dev staging or prod"
        )
        exit()

    event["ENV_NAME"] = environment
    REGION = event["REGION"]

    if environment in ["fda-dev", "pre-prod", "prod"]:
        isgov = "arn:aws-us-gov"
    else:
        isgov = "arn:aws"

    event["EXECUTION_ROLE_ARN"] = (
        f"{isgov}:iam::{account_id}:role/SagemakerFullAccessWithResourceBoundary"
    )
    event["IMAGE"] = (
        f"{account_id}.dkr.ecr.{REGION}.amazonaws.com/mde-{PROJECT_NAME}-{environment}:latest"
    )
    event["stateMachineArn"] = (
        f"{isgov}:states:{REGION}:{account_id}:stateMachine:{PROJECT_NAME}-{environment}-mde"
    )

    etctime = datetime.today() - timedelta(hours=5, minutes=00)

    todayhour = str(etctime.strftime("%Y-%m-%d-%H-%M"))

    # User Input: Enter job name (or multiple jobs) here
    event["JOB_NAME"] = "[ENTER_JOB_NAME]" + todayhour

    event["AWS_DEFAULT_REGION"] = REGION

    print(json.dumps(event, indent=4))

    transactionid = str(uuid.uuid1())

    client = boto3.client("stepfunctions")

    response = client.start_execution(
        stateMachineArn=event["stateMachineArn"],
        name=transactionid,
        input=json.dumps(event),
    )

    time.sleep(1)

    print(response)

    response = client.describe_execution(executionArn=response["executionArn"])
    print(response)

    status = response["status"]

    return status
