#!/bin/sh

Status = 'InProgress'
while [ $Status -eq 'InProgress']
do
    sleep 60
    Status = awscurl -X $1 $2
done

[ $Status -eq 'Failed' ] && exit 1
[ $Status -eq 'Success' ] && exit 0

exit -1
