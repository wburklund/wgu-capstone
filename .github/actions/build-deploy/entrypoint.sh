#!/bin/sh

cd /github/workspace/pipeline/stage5_deploy/
go build deploy.go
zip /github/workspace/stage5_deploy.zip deploy
