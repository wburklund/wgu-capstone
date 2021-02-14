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

resource "aws_ssm_parameter" "capstone_model_instance_id" {
  name  = "/capstone/model_instance_id"
  type  = "String"
  value = aws_instance.capstone_model.id
}

resource "aws_ssm_parameter" "capstone_model_run_execution_id" {
  name  = "/capstone/model_run_execution_id"
  type  = "String"
  value = " "

  lifecycle {
    ignore_changes = [value]
  }
}
