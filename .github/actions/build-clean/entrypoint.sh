#!/bin/sh

cd /github/workspace/pipeline/stage2_clean/
cargo build
dotnet tool restore
dotnet lambda package -o /github/workspace/stage2_clean.zip
#!/bin/sh

cd /github/workspace/pipeline/stage2_clean/
cargo build --release
zip /github/workspace/stage2_clean.zip target/release/bootstrap
