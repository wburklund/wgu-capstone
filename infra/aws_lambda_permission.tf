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

resource "aws_lambda_permission" "capstone_ingest_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage1_ingest.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "capstone_clean_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage2_clean.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "capstone_model_status_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage3_model_status.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "capstone_model_trigger_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage3_model_trigger.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "capstone_test_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage4_test.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "capstone_deploy_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stage5_deploy.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.capstone_pipeline_api.execution_arn}/*/*/*"
}
