#!/bin/sh

cd /github/workspace/pipeline/stage4_test/
./gradlew buildZip
cp build/distributions/stage4_test.zip /github/workspace/stage4_test.zip
