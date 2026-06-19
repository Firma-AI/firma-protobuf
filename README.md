# firma-protobuf

[![license-apache](https://img.shields.io/crates/l/firma-protobuf.svg?logo=rust)](https://opensource.org/licenses/Apache-2.0)
[![repo-stars](https://img.shields.io/github/stars/Firma-AI/firma-protobuf?style=flat)](https://github.com/Firma-AI/firma-protobuf/stargazers)
[![latest-version](https://img.shields.io/crates/v/firma-protobuf.svg?logo=rust)](https://crates.io/crates/firma-protobuf)
[![conventional-commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)

[![ci](https://github.com/Firma-AI/firma-protobuf/actions/workflows/ci.yml/badge.svg)](https://github.com/Firma-AI/firma-protobuf/actions)
[![docs](https://img.shields.io/docsrs/firma-protobuf?logo=docsdotrs)](https://docs.rs/firma-protobuf)

Shared Protobuf/gRPC wire contract for the Firma stack, published as a Rust
crate.

This repository holds the `.proto` definitions for the Firma wire format and
compiles them into Rust types and Tonic service glue. It is the single source of
truth for the Authority, Sidecar, and audit wire formats, consumed by
[openfirma](https://github.com/Firma-AI/openfirma) and
[firma-team](https://github.com/Firma-AI/firma-team) as a crate dependency
(previously a git submodule).

## Layout

```text
proto/
└── firma/
    └── v1/
        ├── audit.proto      # audit event streaming
        ├── authority.proto  # AuthorityService: issuance, policy, revocations
        └── types.proto      # shared message types
src/
└── lib.rs                   # re-exports the generated firma.v1 module
build.rs                     # compiles the .proto via tonic-prost-build
```

## Usage

Add the crate as a dependency:

```toml
[dependencies]
firma-protobuf = "0.1"
```

The `.proto` files are compiled at build time with a vendored `protoc`
(via `protoc-bin-vendored`), so no system `protoc` install is required.
Generated items live under the `v1` module, including both gRPC client and
server stubs:

```rust
use firma_protobuf::v1::{
    ExecutionEnvelope,
    authority_service_client::AuthorityServiceClient,
    authority_service_server::{AuthorityService, AuthorityServiceServer},
};
```

## Development

Tasks run through [`just`](https://github.com/casey/just). Run `just` with no
arguments to list every recipe.

```bash
just install_tools   # install dprint, cargo-audit, cargo-deny; wire git hooks
just check           # CI parity: fmt-check + clippy + test + build + audit + deny
just fmt             # format all sources (TOML, Markdown, Rust) with dprint
just build           # cargo build
just test            # cargo test
just clippy          # cargo clippy --all-targets -- -D warnings
just buf lint        # lint the .proto wire contract with buf
just package         # verify the crate packages cleanly for crates.io
```

Rust 1.88+, edition 2024. Lints are enforced (`clippy::pedantic` deny,
`unsafe_code` deny); generated code is silenced with a scoped `#[allow(...)]`.

### Tooling

The toolchain mirrors the [firma-team](https://github.com/Firma-AI/firma-team)
and [openfirma](https://github.com/Firma-AI/openfirma) stacks. Pinned versions
live in `tool-versions.env` (single source of truth shared by
`just install_tools` and CI):

- [`just`](https://github.com/casey/just) — task runner; recipes live in
  `Justfile` and the `just/` directory
- [`dprint`](https://dprint.dev) — formats TOML, Markdown, and Rust (via
  `rustfmt`); config in `dprint.json`, replaces `cargo fmt` and `taplo`
- [`buf`](https://buf.build) — lints the `.proto` contract and checks wire
  compatibility; config in `buf.yaml`
- [`cargo-audit`](https://github.com/rustsec/rustsec) — RustSec advisory scan
- [`cargo-deny`](https://github.com/EmbarkStudios/cargo-deny) — license, ban,
  and source checks
- [`trufflehog`](https://github.com/trufflesecurity/trufflehog) — secret scan,
  wired into the `.githooks/pre-commit` hook alongside a `dprint` format check

## Versioning and publishing

The wire contract is versioned by package (`firma.v1`). Backward-compatible
changes add fields with new tag numbers; existing field numbers are never reused
or renumbered. A breaking change requires a new package version (`firma.v2`).

The crate is published to [crates.io](https://crates.io/crates/firma-protobuf).
Publishing happens automatically from CI (`.github/workflows/publish.yml`) when
a GitHub release is published, using crates.io trusted publishing (OIDC). The
release tag (e.g. `v0.1.0`) must match the version in `Cargo.toml`.

## License

Licensed under the [Apache License, Version 2.0](LICENSE).
