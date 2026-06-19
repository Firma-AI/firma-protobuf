# Format all sources (TOML, Markdown and Rust via rustfmt) with dprint
[group('code_check')]
fmt args="":
    dprint fmt {{ args }}

# Check formatting of all sources with dprint (no writes)
[group('code_check')]
fmt_check args="":
    dprint check {{ args }}

# Run clippy on the crate, denying warnings
[group('code_check')]
clippy args="":
    cargo clippy --all-targets {{ args }} -- -D warnings

# Lint the .proto wire contract with buf
[group('code_check')]
buf args="lint":
    buf {{ args }}

# Audit dependencies for security advisories (cargo-audit)
[group('code_check')]
audit:
    cargo audit --deny warnings

# Check dependencies for licenses, bans and sources (cargo-deny)
[group('code_check')]
deny:
    cargo deny check licenses bans sources

# Run all code checks (CI parity). Fails if any check fails
[group('code_check')]
check: fmt_check clippy test build audit deny
