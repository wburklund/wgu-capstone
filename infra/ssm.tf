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

resource "aws_ssm_document" "Start_ShellScript_Stop" {
  document_format = "YAML"
  document_type   = "Automation"
  name            = "Start-ShellScript-Stop"

  content = <<EOF
description: ''
schemaVersion: '0.3'
assumeRole: 'arn:aws:iam::${local.account_id}:role/SSMAutomation'
parameters:
  InstanceId:
    type: StringList
  RunShellScriptParameters:
    type: StringMap
mainSteps:
  - name: startInstance
    action: 'aws:changeInstanceState'
    inputs:
      DesiredState: running
      InstanceIds: '{{ InstanceId }}'
    description: ''
  - name: runShellScript
    action: 'aws:runCommand'
    inputs:
      InstanceIds: '{{ InstanceId }}'
      DocumentName: AWS-RunShellScript
      Parameters: '{{ RunShellScriptParameters }}'
    description: ''
    onFailure: Continue
    timeoutSeconds: 7200    
  - name: stopInstance
    action: 'aws:changeInstanceState'
    inputs:
      InstanceIds: '{{ InstanceId }}'
      DesiredState: stopped
EOF 
}

resource "aws_ssm_parameter" "capstone_clean_exclusion_list" {
  name  = "/capstone/clean_exclusion_list"
  type  = "StringList"
  value = file("assets/exclusion_list.txt")
}

resource "aws_ssm_parameter" "capstone_model_run_instance_id" {
  name  = "/capstone/model_run_instance_id"
  type  = "String"
  value = aws_instance.capstone_model_run.id
}

resource "aws_ssm_parameter" "capstone_model_run_execution_id" {
  name  = "/capstone/model_run_execution_id"
  type  = "String"
  value = " "

  lifecycle {
    ignore_changes = [value]
  }
}
