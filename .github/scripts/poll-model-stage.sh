#!/bin/sh

STATUS='InProgress'
while [[ "$STATUS" == 'InProgress' ]]
do
    sleep 60
    STATUS=$(awscurl -X $1 $2)
done

[ "$STATUS" == 'Failed' ] && exit 1
[ "$STATUS" == 'Success' ] && exit 0

exit 42
