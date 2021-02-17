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
                "${aws_s3_bucket.capstone_model_input.arn}",
                "${aws_s3_bucket.capstone_test_answers.arn}"                
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
            "Resource": [
                "${aws_s3_bucket.capstone_model_input.arn}/*",
                "${aws_s3_bucket.capstone_test_answers.arn}/*"
            ]
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
