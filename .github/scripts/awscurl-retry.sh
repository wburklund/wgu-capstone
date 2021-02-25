#!/bin/sh

timeout "$3" sh -c "until awscurl --service execute-api -X $1 $2; do sleep 1; done"
