#!/bin/sh

timeout -k 10 "$3" sh -c 'until awscurl --service execute-api -X "$1" "$2"; do sleep "$3"; done'
