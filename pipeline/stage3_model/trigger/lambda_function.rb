=begin
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
=end

require 'aws-sdk-lambda'
require 'aws-sdk-ssm'
require 'json'

def lambda_handler(event:, context:)
    lambdaClient = Aws::Lambda::Client.new()
    ssmClient = Aws::SSM::Client.new()
    
    resp = lambdaClient.invoke({ function_name: ENV['status_function_name'] })
    if resp.status_code >= 400
        return { statusCode: 500, body: 'Error checking execution status:' + resp.payload.string }
    end
    
    payload = JSON.parse(resp.payload.string)
    if payload['body'] == 'InProgress'
        return { statusCode: 409, body: 'Failed to start modeling stage. Stage is currently running!' }
    end
    
    instance_id = ssmClient.get_parameter({ name: ENV['instance_parameter_key'] }).parameter.value
    
    resp = ssmClient.start_automation_execution({
        document_name: ENV['model_run_document'],
        parameters: { "InstanceId" => [instance_id],
        "RunShellScriptParameters" => ['{ "commands": "%s", "executionTimeout": "%s" }' % [ENV['commands'], ENV['timeout_seconds']]]
        }
    })
    ssmClient.put_parameter({ name: ENV['execution_parameter_key'], value: resp.automation_execution_id, type: "String", overwrite: true})
    
    { statusCode: 202, body: JSON.generate("Modeling stage started.") }
end 
