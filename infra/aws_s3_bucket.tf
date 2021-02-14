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

resource "aws_s3_bucket" "capstone_code_store" {
  bucket = "capstone-code-store"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "capstone_data_store" {
  bucket = "capstone-data-store"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "capstone_model_input" {
  bucket = "capstone-model-input"
}

resource "aws_s3_bucket" "capstone_model_output" {
  bucket = "capstone-model-output"
}

resource "aws_s3_bucket" "capstone_test_answers" {
  bucket = "capstone-test-answers"
}

resource "aws_s3_bucket" "capstone_deploy_artifacts" {
  bucket = "capstone-deploy-artifacts"
}

resource "aws_s3_bucket" "capstone_pipeline_lambdas" {
  bucket = "capstone-pipeline-lambdas"
}

resource "aws_s3_bucket" "capstone_api_assets" {
  bucket = "capstone-api-assets"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "capstone_web_assets" {
  bucket = "capstone-web-assets"

  versioning {
    enabled = true
  }
}
