#!/bin/sh

timeout "$3" sh -c "until awscurl -X $1 $2; do sleep 1; done"
