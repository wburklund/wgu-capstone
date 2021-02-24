#!/bin/sh

for zip in $(find -name "*.zip")
do
        openssl dgst -sha256 -binary $zip | openssl enc -base64 > $zip.sha256.txt
done
