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

resource "aws_apigatewayv2_api_mapping" "capstone_pipeline" {
  api_id      = aws_apigatewayv2_api.capstone_pipeline_api.id
  domain_name = aws_apigatewayv2_domain_name.capstone_pipeline.id
  stage       = aws_apigatewayv2_stage.capstone_pipeline_api.id
}

resource "aws_apigatewayv2_api" "capstone_pipeline_api" {
  name          = "CapstonePipeline"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_domain_name" "capstone_pipeline" {
  domain_name = "capstone-pipeline.${data.aws_acm_certificate.wildcard.domain}"

  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.wildcard.arn
    endpoint_type = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

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

resource "aws_apigatewayv2_route" "ingest" {
  api_id    = aws_apigatewayv2_api.capstone_pipeline_api.id
  authorization_type = "AWS_IAM"
  route_key = "PUT /ingest"
  target = "integrations/${aws_apigatewayv2_integration.ingest.id}"
}

resource "aws_apigatewayv2_route" "clean" {
  api_id    = aws_apigatewayv2_api.capstone_pipeline_api.id
  authorization_type = "AWS_IAM"
  route_key = "PUT /clean"
  target = "integrations/${aws_apigatewayv2_integration.clean.id}"
}

resource "aws_apigatewayv2_route" "model_status" {
  api_id    = aws_apigatewayv2_api.capstone_pipeline_api.id
  authorization_type = "AWS_IAM"
  route_key = "GET /model"
  target = "integrations/${aws_apigatewayv2_integration.model_status.id}"
}

resource "aws_apigatewayv2_route" "model_trigger" {
  api_id    = aws_apigatewayv2_api.capstone_pipeline_api.id
  authorization_type = "AWS_IAM"
  route_key = "POST /model"
  target = "integrations/${aws_apigatewayv2_integration.model_trigger.id}"
}

resource "aws_apigatewayv2_route" "test" {
  api_id    = aws_apigatewayv2_api.capstone_pipeline_api.id
  authorization_type = "AWS_IAM"
  route_key = "PUT /test"
  target = "integrations/${aws_apigatewayv2_integration.test.id}"
}

resource "aws_apigatewayv2_route" "deploy" {
  api_id    = aws_apigatewayv2_api.capstone_pipeline_api.id
  authorization_type = "AWS_IAM"
  route_key = "PUT /deploy"
  target = "integrations/${aws_apigatewayv2_integration.deploy.id}"
}

resource "aws_apigatewayv2_stage" "capstone_pipeline_api" {
  api_id = aws_apigatewayv2_api.capstone_pipeline_api.id
  auto_deploy = true
  name   = "$default"
}
