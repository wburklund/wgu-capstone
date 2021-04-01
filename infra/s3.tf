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

data "aws_s3_bucket" "capstone_code_store" {
  bucket = "capstone-code-store"
}

data "aws_s3_bucket" "capstone_data_store" {
  bucket = "capstone-data-store"
}

data "aws_s3_bucket_object" "stage1_ingest_hash" {
  bucket = data.aws_s3_bucket.capstone_code_store.bucket
  key    = "stage1_ingest.zip.sha256.txt"
}

data "aws_s3_bucket_object" "stage2_clean_hash" {
  bucket = data.aws_s3_bucket.capstone_code_store.bucket
  key    = "stage2_clean.zip.sha256.txt"
}

data "aws_s3_bucket_object" "stage3_model_status_hash" {
  bucket = data.aws_s3_bucket.capstone_code_store.bucket
  key    = "stage3_model_status.zip.sha256.txt"
}

data "aws_s3_bucket_object" "stage3_model_trigger_hash" {
  bucket = data.aws_s3_bucket.capstone_code_store.bucket
  key    = "stage3_model_trigger.zip.sha256.txt"
}

data "aws_s3_bucket_object" "stage4_test_hash" {
  bucket = data.aws_s3_bucket.capstone_code_store.bucket
  key    = "stage4_test.zip.sha256.txt"
}

data "aws_s3_bucket_object" "stage5_deploy_hash" {
  bucket = data.aws_s3_bucket.capstone_code_store.bucket
  key    = "stage5_deploy.zip.sha256.txt"
}

resource "aws_s3_bucket" "capstone_model_input" {
  bucket = "capstone-model-input"
}

resource "aws_s3_bucket" "capstone_model_output" {
  bucket = "capstone-model-output"
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

resource "aws_s3_bucket_object" "capstone_web_assets" {
  for_each = fileset(var.upload_directory, "**/*.*")

  bucket       = aws_s3_bucket.capstone_web_assets.bucket
  key          = replace(each.value, var.upload_directory, "")
  source       = "${var.upload_directory}${each.value}"
  etag         = filemd5("${var.upload_directory}${each.value}")
  content_type = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}

resource "aws_s3_bucket_policy" "capstone_web_assets" {
  bucket = aws_s3_bucket.capstone_web_assets.bucket

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.capstone_web.id}"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.capstone_web_assets.arn}/*"
        }
    ]
}
EOF
}