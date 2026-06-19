# AGENTS.md

Guidance for coding agents working in this repository.

## What this repository is

`firma-protobuf` is the published Rust crate for the Firma `firma.v1`
Protobuf/gRPC wire contract. The `.proto` files under `proto/firma/v1/` are the
single source of truth; `build.rs` compiles them into Rust types and Tonic
service glue via `tonic-prost-build` (with a vendored `protoc`, so no system
`protoc` is required). Consumers — openfirma and firma-team — depend on the
published crate instead of vendoring the `.proto` as a submodule.

## Build Commands

Tasks run through [`just`](https://github.com/casey/just) (recipes in `Justfile`
and `just/`). Run `just` with no arguments to list them.

```bash
just check    # fmt-check + clippy + test + build + audit + deny (CI parity)
just fmt      # dprint fmt — format TOML + Markdown + Rust
just clippy   # cargo clippy --all-targets -- -D warnings
just test     # cargo test
just build    # cargo build
just buf lint # lint the .proto wire contract with buf
just package  # verify the crate packages cleanly for crates.io
```

## Conventions

- Rust 1.88+, edition 2024. Lints are strict and CI-enforced (`clippy::pedantic`
  deny, `unsafe_code` deny). Generated Tonic/Prost code is silenced with a
  scoped `#[allow(...)]` on the `v1` module in `src/lib.rs` — never hand-edit
  generated output.
- Run `just fmt` after editing any `.toml`, `.md`, or `.rs` file (`dprint`
  formats all three; it replaces `cargo fmt` and `taplo`).
- Commits must follow [Conventional Commits](https://www.conventionalcommits.org/);
  a `cog check` job enforces this on pull requests.
- Never commit implementation plans. Write them under `.claude/plans/` only,
  which is gitignored.

## Wire compatibility

The contract is versioned by package (`firma.v1`). Backward-compatible changes
add fields with **new tag numbers**; existing field numbers are **never** reused
or renumbered. A breaking change requires a new package version (`firma.v2`).
`buf` enforces wire compatibility on pull requests.
