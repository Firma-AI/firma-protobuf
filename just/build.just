# Build the crate
[group('build')]
build args="":
    cargo build {{ args }}

# Build the crate in release mode
[group('build')]
build_release:
    just build "--release"

# Verify the crate packages cleanly for crates.io (no upload)
[group('build')]
package:
    cargo package
