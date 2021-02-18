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

resource "aws_iam_role_policy_attachment" "capstone_model_run__AmazonSSMManagedInstanceCore" {
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  role       = aws_iam_role.capstone_model_run.name
}

resource "aws_iam_role_policy_attachment" "capstone_model_run__CloudWatchLogsFullAccess" {
  policy_arn = data.aws_iam_policy.CloudWatchLogsFullAccess.arn
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
