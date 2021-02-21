#!/bin/sh

mkdir -p artifacts/stage3_model_run
cd /github/workspace/pipeline/stage3_model/

cp run/* /github/workspace/artifacts/stage3_model_run/
zip /github/workspace/artifacts/stage3_model_status.zip status/index.js
zip /github/workspace/artifacts/stage3_model_trigger.zip trigger/lambda_function.rb
 