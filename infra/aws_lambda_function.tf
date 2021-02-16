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

resource "aws_lambda_function" "stage1_ingest" {
  function_name = "capstone_stage1_ingest"
  handler       = "ingest::ingest.Function::FunctionHandler"
  memory_size   = 1024 # Lambda compute power is proportional to memory
  role          = aws_iam_role.capstone_ingest.arn
  runtime       = "dotnetcore3.1"
  timeout       = 60
  s3_bucket     = aws_s3_bucket.capstone_code_store.bucket
  s3_key        = "stage1_ingest.zip"
  # TODO: SHA256 (see https://github.com/hashicorp/terraform/issues/12443#issuecomment-291922062)
  # source_code_hash = "value"

  environment {
    variables = {
      "dataStoreBucket"   = "capstone-data-store",
      "metadataObjectKey" = "Chest_xray_Corona_Metadata.Augmented.csv",
      "destinationBucket" = "capstone-model-input",
      "sourceKeyPrefix"   = "Coronahack-Chest-XRay-Dataset/Coronahack-Chest-XRay-Dataset"
    }
  }
}

resource "aws_lambda_function" "stage2_clean" {
  function_name = "capstone_stage2_clean"
  handler       = "provided"
  role          = aws_iam_role.capstone_clean.arn
  runtime       = "provided.al2"
  timeout       = 15
  s3_bucket     = aws_s3_bucket.capstone_code_store.bucket
  s3_key        = "stage2_clean.zip"
  # TODO: SHA256 (see https://github.com/hashicorp/terraform/issues/12443#issuecomment-291922062)
  # source_code_hash = "value"

  environment {
    variables = {
      "S3_BUCKET"                = "capstone-model-input",
      "EXCLUSION_LIST_PARAMETER" = aws_ssm_parameter.capstone_clean_exclusion_list.name
    }
  }
}

resource "aws_lambda_function" "stage3_model_status" {
  function_name = "capstone_stage3_model_status"
  handler       = "index.handler"
  role          = aws_iam_role.capstone_model_status.arn
  runtime       = "nodejs14.x"
  s3_bucket     = aws_s3_bucket.capstone_code_store.bucket
  s3_key        = "stage3_model_status.zip"
  # TODO: SHA256 (see https://github.com/hashicorp/terraform/issues/12443#issuecomment-291922062)
  # source_code_hash = "value"

  environment {
    variables = {
      "execution_parameter_initial_value" = " ",
      "execution_parameter_key"           = aws_ssm_parameter.capstone_model_run_execution_id.name,
      "model_run_document"                = aws_ssm_document.Start_ShellScript_Stop.arn
    }
  }
}

resource "aws_lambda_function" "stage3_model_trigger" {
  function_name = "capstone_stage3_model_trigger"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.capstone_model_trigger.arn
  runtime       = "ruby2.7"
  s3_bucket     = aws_s3_bucket.capstone_code_store.bucket
  s3_key        = "stage3_model_trigger.zip"
  # TODO: SHA256 (see https://github.com/hashicorp/terraform/issues/12443#issuecomment-291922062)
  # source_code_hash = "value"

  environment {
    variables = {
      "execution_parameter_key" = aws_ssm_parameter.capstone_model_run_execution_id.name,
      "instance_parameter_key"  = aws_ssm_parameter.capstone_model_run_instance_id.name,
      "model_run_document"      = aws_ssm_document.Start_ShellScript_Stop.arn
      "s3_bucket"               = aws_s3_bucket.capstone_code_store.bucket
      "s3_key"                  = "stage3_model_run"
      "status_function_name"    = aws_lambda_function.stage3_model_status.function_name
    }
  }
}
