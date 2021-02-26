#!/bin/sh

timeout "$3" sh -c "until awscurl -X $1 $2 != 'InProgress'; do sleep 60; done"

$Result = awscurl -X $1 $2

[ $Result -eq 'Failed' ] && exit 1
[ $Result -eq 'Success' ] && exit 0

exit -1
