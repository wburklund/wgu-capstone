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

const AWS = require('aws-sdk');

exports.handler = async (event) => {
    const ssm = new AWS.SSM();
    
    const parameterParams = { Name: process.env.execution_parameter_key };
    let executionId = (await ssm.getParameter(parameterParams).promise()).Parameter.Value;
    
    // No execution has ever been started, treat as 'Failed' as there are no results to use
    if (executionId === process.env.execution_parameter_initial_value) {
        return { statusCode: 200, body: 'Failed' };
    }
    
    let executionParams = { AutomationExecutionId: executionId };
    let execution = (await ssm.getAutomationExecution(executionParams).promise()).AutomationExecution;
    if (execution.DocumentName !== process.env.model_run_document) {
        return { statusCode: 500, body: `Internal error: unexpected document name ${execution.DocumentName}!` };
    }
    
    if (['Pending', 'InProgress', 'Waiting', 'Cancelling'].includes(execution.AutomationExecutionStatus)) {
        return { statusCode: 200, body: 'InProgress' };
    }
    
    if (['TimedOut', 'Cancelled', 'Failed'].includes(execution.AutomationExecutionStatus)) {
        return { statusCode: 200, body: 'Failed' };
    }
    
    if (execution.AutomationExecutionStatus === 'Success') {
        let step = execution.StepExecutions[1];  // ShellScript step
        if (['TimedOut', 'Cancelled', 'Failed'].includes(step.StepStatus)) {
            return { statusCode: 200, body: 'Failed' };
        }
        if (step.StepStatus === 'Success') {
            return { statusCode: 200, body: 'Success' };
        }
    }

    return { statusCode: 500, body: `Internal error: unrecognized execution state: "${JSON.stringify(execution)}"` };
};
