#!/bin/sh

cd /github/workspace/pipeline/stage2_clean/
cargo build
zip /github/workspace/stage2_clean.zip target/debug/bootstrap
