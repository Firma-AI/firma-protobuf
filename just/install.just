# Install dev tools (dprint, cargo-audit, cargo-deny) and wire git hooks.
# Versions come from tool-versions.env (loaded via Justfile dotenv settings).
[group('install')]
install_tools:
    #!/usr/bin/env sh
    set -e
    if ! command -v dprint >/dev/null 2>&1; then
        echo "Installing dprint $DPRINT_VERSION..."
        curl -fsSL https://dprint.dev/install.sh | sh -s "$DPRINT_VERSION"
    fi
    command -v cargo-audit >/dev/null 2>&1 || cargo install cargo-audit --version "$CARGO_AUDIT_VERSION" --locked
    command -v cargo-deny >/dev/null 2>&1 || cargo install cargo-deny --version "$CARGO_DENY_VERSION" --locked
    if ! command -v buf >/dev/null 2>&1; then
        echo "warning: buf not found — install from https://buf.build/docs/installation" >&2
        echo "         (macOS: brew install bufbuild/buf/buf)" >&2
    fi
    if ! command -v trufflehog >/dev/null 2>&1; then
        echo "warning: trufflehog not found — install from https://github.com/trufflesecurity/trufflehog/releases" >&2
        echo "         (macOS: brew install trufflehog)" >&2
    fi
    git config core.hooksPath .githooks
    echo "Git hooks wired to .githooks/"
