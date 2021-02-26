#!/bin/sh

Status='InProgress'
while [ $Status == 'InProgress' ]
do
    sleep 60
    Status=$(awscurl -X $1 $2)
done

[ $Status == 'Failed' ] && exit 1
[ $Status == 'Success' ] && exit 0

exit 42
