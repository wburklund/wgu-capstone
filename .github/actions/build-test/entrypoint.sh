#!/bin/sh

cd /github/workspace/pipeline/stage4_test/
./gradlew buildZip
cp build/distributions/test-1.0.zip /github/workspace/stage4_test.zip
