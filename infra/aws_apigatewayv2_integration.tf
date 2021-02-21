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

resource "aws_apigatewayv2_integration" "ingest" {
  api_id = aws_apigatewayv2_api.capstone_pipeline_api.id
  integration_method = "POST"
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.stage1_ingest.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "clean" {
  api_id = aws_apigatewayv2_api.capstone_pipeline_api.id
  integration_method = "POST"
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.stage2_clean.invoke_arn
  # Use payload format 1.0, as Rust's payload format 2.0 integration appears to be broken
}

resource "aws_apigatewayv2_integration" "model_status" {
  api_id = aws_apigatewayv2_api.capstone_pipeline_api.id
  integration_method = "POST"
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.stage3_model_status.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "model_trigger" {
  api_id = aws_apigatewayv2_api.capstone_pipeline_api.id
  integration_method = "POST"
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.stage3_model_trigger.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "test" {
  api_id = aws_apigatewayv2_api.capstone_pipeline_api.id
  integration_method = "POST"
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.stage4_test.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "deploy" {
  api_id = aws_apigatewayv2_api.capstone_pipeline_api.id
  integration_method = "POST"
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.stage5_deploy.invoke_arn
  payload_format_version = "2.0"
}
