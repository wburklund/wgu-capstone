#!/bin/sh

cd /github/workspace/pipeline/stage1_ingest/
dotnet tool restore
dotnet lambda package -o /github/workspace/stage1_ingest.zip
