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
