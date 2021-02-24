#!/bin/sh

set -x

mkdir -p artifacts

if [ -d "stage1_ingest" ]; then
    mv stage1_ingest/* artifacts/
fi
if [ -d "stage2_clean" ]; then
    mv stage2_clean/* artifacts/
fi
if [ -d "stage3_model" ]; then
    mv stage3_model/* artifacts/
fi
if [ -d "stage4_test" ]; then
    mv stage4_test/* artifacts/
fi
if [ -d "stage5_deploy" ]; then
    mv stage5_deploy/* artifacts/
fi
exit 0
