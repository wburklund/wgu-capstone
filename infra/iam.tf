/*
  WGU Capstone Project
  Copyright (C) 2021 Will Burklund

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_role" "ecs_instance" {
  name = "ecsInstanceRole"
}

resource "aws_iam_instance_profile" "capstone_api" {
  name = "capstone_api"
  role = data.aws_iam_role.ecs_instance.name
}

resource "aws_iam_instance_profile" "capstone_model_run" {
  name = "capstone_model_run"
  role = aws_iam_role.capstone_model_run.name
}

resource "aws_iam_role_policy_attachment" "capstone_model_run__AmazonSSMManagedInstanceCore" {
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  role       = aws_iam_role.capstone_model_run.name
}

resource "aws_iam_role_policy_attachment" "capstone_model_run__CloudWatchAgentServerPolicy" {
  policy_arn = data.aws_iam_policy.CloudWatchAgentServerPolicy.arn
  role       = aws_iam_role.capstone_model_run.name
}

resource "aws_iam_role_policy_attachment" "capstone_ingest__logging" {
  policy_arn = module.stage1_ingest_logging_policy.arn
  role       = aws_iam_role.capstone_ingest.name
}

resource "aws_iam_role_policy_attachment" "capstone_clean__logging" {
  policy_arn = module.stage2_clean_logging_policy.arn
  role       = aws_iam_role.capstone_clean.name
}

resource "aws_iam_role_policy_attachment" "capstone_model_status__logging" {
  policy_arn = module.stage3_model_status_logging_policy.arn
  role       = aws_iam_role.capstone_model_status.name
}

resource "aws_iam_role_policy_attachment" "capstone_model_trigger__logging" {
  policy_arn = module.stage3_model_trigger_logging_policy.arn
  role       = aws_iam_role.capstone_model_trigger.name
}

resource "aws_iam_role_policy_attachment" "capstone_test__logging" {
  policy_arn = module.stage4_test_logging_policy.arn
  role       = aws_iam_role.capstone_test.name
}

resource "aws_iam_role_policy_attachment" "capstone_deploy__logging" {
  policy_arn = module.stage5_deploy_logging_policy.arn
  role       = aws_iam_role.capstone_deploy.name
}

resource "aws_iam_role_policy" "capstone_ingest_policy" {
  name = "capstone_ingest_policy"
  role = aws_iam_role.capstone_ingest.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": [
                "${data.aws_s3_bucket.capstone_data_store.arn}",
                "${aws_s3_bucket.capstone_model_input.arn}"              
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "${data.aws_s3_bucket.capstone_data_store.arn}/*"
        },        
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "${aws_s3_bucket.capstone_model_input.arn}/*"
        },
        {
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "${data.aws_dynamodb_table.capstone_metadatabase.arn}"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy" "capstone_clean_policy" {
  name = "capstone_clean_policy"
  role = aws_iam_role.capstone_clean.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ssm:GetParameter",
            "Effect": "Allow",
            "Resource": "${aws_ssm_parameter.capstone_clean_exclusion_list.arn}"

        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "${aws_s3_bucket.capstone_model_input.arn}"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "${aws_s3_bucket.capstone_model_input.arn}/*"
        }           
    ]    
}
    EOF
}

resource "aws_iam_role_policy" "capstone_model_run_policy" {
  name = "capstone_model_run_policy"
  role = aws_iam_role.capstone_model_run.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": [
                "${data.aws_s3_bucket.capstone_code_store.arn}",
                "${aws_s3_bucket.capstone_model_input.arn}",
                "${aws_s3_bucket.capstone_model_output.arn}"                
            ]
        },        
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "${data.aws_s3_bucket.capstone_code_store.arn}/stage3_model_run/*",
                "${aws_s3_bucket.capstone_model_input.arn}/*",
                "${aws_s3_bucket.capstone_model_output.arn}/*"            
            ]
        },        
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "${aws_s3_bucket.capstone_model_output.arn}/*"
        }
    ]
}
  EOF
}


resource "aws_iam_role_policy" "capstone_model_status_policy" {
  name = "capstone_model_status_policy"
  role = aws_iam_role.capstone_model_status.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ssm:GetParameter",
            "Effect": "Allow",
            "Resource": "${aws_ssm_parameter.capstone_model_run_execution_id.arn}"

        },
        {
            "Action": "ssm:GetAutomationExecution",
            "Effect": "Allow",
            "Resource": "*"
        }
    ]    
}
    EOF
}

resource "aws_iam_role_policy" "capstone_model_trigger_policy" {
  name = "capstone_model_trigger_policy"
  role = aws_iam_role.capstone_model_trigger.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ssm:*",
            "Effect": "Allow",
            "Resource": [
                "${aws_ssm_document.Start_ShellScript_Stop.arn}",
                "arn:aws:ssm:${local.region}:${local.account_id}:*",
                "arn:aws:ec2:${local.region}:${local.account_id}:instance/*",
                "arn:aws:ssm:${local.region}:${local.account_id}:automation-definition/${aws_ssm_document.Start_ShellScript_Stop.name}:$DEFAULT",
                "arn:aws:ssm:${local.region}::document/AWS-RunShellScript"
            ]
        },
        {
            "Action": "ssm:GetParameter",
            "Effect": "Allow",
            "Resource": "${aws_ssm_parameter.capstone_model_run_instance_id.arn}"

        },
        {
            "Action": "ssm:PutParameter",
            "Effect": "Allow",
            "Resource": "${aws_ssm_parameter.capstone_model_run_execution_id.arn}"
        },
        {
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "${aws_lambda_function.stage3_model_status.arn}"
        }        
    ]    
}
    EOF
}

resource "aws_iam_role_policy" "capstone_test_policy" {
  name = "capstone_test_policy"
  role = aws_iam_role.capstone_test.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": [
                "${aws_s3_bucket.capstone_model_output.arn}",
                "${aws_s3_bucket.capstone_deploy_artifacts.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "${aws_s3_bucket.capstone_model_output.arn}/*"
        },        
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "${aws_s3_bucket.capstone_deploy_artifacts.arn}/*"
        },
        {
            "Effect": "Allow",
            "Action": "dynamodb:Scan",
            "Resource": "${data.aws_dynamodb_table.capstone_metadatabase.arn}"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy" "capstone_deploy_policy" {
  name = "capstone_deploy_policy"
  role = aws_iam_role.capstone_deploy.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": [
                "${aws_s3_bucket.capstone_deploy_artifacts.arn}",
                "${aws_s3_bucket.capstone_api_assets.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "${aws_s3_bucket.capstone_deploy_artifacts.arn}/*"
        },        
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "${aws_s3_bucket.capstone_api_assets.arn}/*"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy" "capstone_api_policy" {
  name = "capstone_api_policy"
  role = aws_iam_role.capstone_api.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "${aws_s3_bucket.capstone_api_assets.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "${aws_s3_bucket.capstone_api_assets.arn}/*"
        },
        {
            "Effect": "Allow",
            "Action": "dynamodb:Scan",
            "Resource": "${data.aws_dynamodb_table.capstone_metadatabase.arn}"     
        }        
    ]
}
  EOF
}

resource "aws_iam_role" "capstone_ingest" {
  name = "capstone_ingest"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF  
}

resource "aws_iam_role" "capstone_clean" {
  name = "capstone_clean"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_role" "capstone_model_run" {
  name = "capstone_model_run"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "capstone_model_status" {
  name = "capstone_model_status"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "capstone_model_trigger" {
  name = "capstone_model_trigger"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "capstone_test" {
  name = "capstone_test"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "capstone_deploy" {
  name = "capstone_deploy"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "capstone_api" {
  name = "capstone_api"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}