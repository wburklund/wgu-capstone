#!/bin/sh

while timeout -k 10 $3 -- awscurl --service execute-api -X $1 $2; [ $? = 124 ]
do sleep $4
done
