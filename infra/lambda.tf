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
  function_name    = "capstone_stage1_ingest"
  handler          = "ingest::ingest.Function::FunctionHandler"
  memory_size      = 1024 # Lambda compute power is proportional to memory
  role             = aws_iam_role.capstone_ingest.arn
  runtime          = "dotnetcore3.1"
  s3_bucket        = data.aws_s3_bucket.capstone_code_store.bucket
  s3_key           = "stage1_ingest.zip"
  source_code_hash = chomp(data.aws_s3_bucket_object.stage1_ingest_hash.body) # Thanks to https://stackoverflow.com/a/64713147
  timeout          = 60

  environment {
    variables = {
      "dataStoreBucket"       = data.aws_s3_bucket.capstone_data_store.bucket,
      "metadataObjectKey"     = "Chest_xray_Corona_Metadata.Augmented.csv",
      "destinationBucket"     = aws_s3_bucket.capstone_model_input.bucket,
      "sourceKeyPrefix"       = "Coronahack-Chest-XRay-Dataset/Coronahack-Chest-XRay-Dataset",
      "metadatabaseTableName" = data.aws_dynamodb_table.capstone_metadatabase.name
    }
  }
}

resource "aws_lambda_function" "stage2_clean" {
  function_name    = "capstone_stage2_clean"
  handler          = "provided"
  role             = aws_iam_role.capstone_clean.arn
  runtime          = "provided.al2"
  s3_bucket        = data.aws_s3_bucket.capstone_code_store.bucket
  s3_key           = "stage2_clean.zip"
  source_code_hash = chomp(data.aws_s3_bucket_object.stage2_clean_hash.body)
  timeout          = 15

  environment {
    variables = {
      "S3_BUCKET"                = aws_s3_bucket.capstone_model_input.bucket,
      "EXCLUSION_LIST_PARAMETER" = aws_ssm_parameter.capstone_clean_exclusion_list.name
    }
  }
}

resource "aws_lambda_function" "stage3_model_status" {
  function_name    = "capstone_stage3_model_status"
  handler          = "index.handler"
  role             = aws_iam_role.capstone_model_status.arn
  runtime          = "nodejs14.x"
  s3_bucket        = data.aws_s3_bucket.capstone_code_store.bucket
  s3_key           = "stage3_model_status.zip"
  source_code_hash = chomp(data.aws_s3_bucket_object.stage3_model_status_hash.body)

  environment {
    variables = {
      "execution_parameter_initial_value" = " ",
      "execution_parameter_key"           = aws_ssm_parameter.capstone_model_run_execution_id.name,
      "model_run_document"                = aws_ssm_document.Start_ShellScript_Stop.arn
    }
  }
}

resource "aws_lambda_function" "stage3_model_trigger" {
  function_name    = "capstone_stage3_model_trigger"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.capstone_model_trigger.arn
  runtime          = "ruby2.7"
  s3_bucket        = data.aws_s3_bucket.capstone_code_store.bucket
  s3_key           = "stage3_model_trigger.zip"
  source_code_hash = chomp(data.aws_s3_bucket_object.stage3_model_trigger_hash.body)

  environment {
    variables = {
      "execution_parameter_key" = aws_ssm_parameter.capstone_model_run_execution_id.name,
      "instance_parameter_key"  = aws_ssm_parameter.capstone_model_run_instance_id.name,
      "model_run_document"      = aws_ssm_document.Start_ShellScript_Stop.arn,
      "s3_bucket"               = data.aws_s3_bucket.capstone_code_store.bucket,
      "s3_key"                  = "stage3_model_run",
      "status_function_name"    = aws_lambda_function.stage3_model_status.function_name,
      "timeout_seconds"         = 7200
    }
  }
}

resource "aws_lambda_function" "stage4_test" {
  function_name    = "capstone_stage4_test"
  handler          = "Handler"
  memory_size      = 512
  role             = aws_iam_role.capstone_test.arn
  runtime          = "java11"
  s3_bucket        = data.aws_s3_bucket.capstone_code_store.bucket
  s3_key           = "stage4_test.zip"
  source_code_hash = chomp(data.aws_s3_bucket_object.stage4_test_hash.body)
  timeout          = 60

  environment {
    variables = {
      "destinationBucket" = aws_s3_bucket.capstone_deploy_artifacts.bucket,
      "metadatabaseTable" = data.aws_dynamodb_table.capstone_metadatabase.name,
      "modelFileKey"      = "model.h5",
      "predictionFileKey" = "predictions.csv",
      "sourceBucket"      = aws_s3_bucket.capstone_model_output.bucket
    }
  }
}

resource "aws_lambda_function" "stage5_deploy" {
  function_name    = "capstone_stage5_deploy"
  handler          = "deploy"
  role             = aws_iam_role.capstone_deploy.arn
  runtime          = "go1.x"
  s3_bucket        = data.aws_s3_bucket.capstone_code_store.bucket
  s3_key           = "stage5_deploy.zip"
  source_code_hash = chomp(data.aws_s3_bucket_object.stage5_deploy_hash.body)
  timeout          = 10

  environment {
    variables = {
      "destination_bucket" = aws_s3_bucket.capstone_api_assets.bucket,
      "model_key"          = "model.h5",
      "source_bucket"      = aws_s3_bucket.capstone_deploy_artifacts.bucket
    }
  }
}

resource "aws_lambda_permission" "capstone_ingest_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage1_ingest.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "capstone_clean_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage2_clean.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "capstone_model_status_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage3_model_status.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "capstone_model_trigger_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage3_model_trigger.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "capstone_test_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage4_test.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "capstone_deploy_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage5_deploy.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}
