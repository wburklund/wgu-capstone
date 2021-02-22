#!/bin/sh

set -x

mkdir -p artifacts

[ -d "stage1_ingest" ] && mv stage1_ingest/* artifacts/
[ -d "stage2_clean" ] && mv stage2_clean/* artifacts/
[ -d "stage3_model" ] && mv stage3_model/* artifacts/
[ -d "stage4_test" ] && mv stage4_test/* artifacts/
[ -d "stage5_deploy" ] && mv stage5_deploy/* artifacts/
