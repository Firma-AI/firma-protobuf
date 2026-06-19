# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

`firma-protobuf` is the published Rust crate for the Firma `firma.v1`
Protobuf/gRPC wire contract. The `.proto` definitions under `proto/firma/v1/`
are the single source of truth for the Firma wire format; `build.rs` compiles
them into Rust types and Tonic service glue via `tonic-prost-build`, using a
vendored `protoc` (`protoc-bin-vendored`) so no system `protoc` is required.
`src/lib.rs` re-exports the generated code under the `v1` module (both gRPC
client and server stubs).

The crate is published to crates.io and consumed by
[openfirma](https://github.com/Firma-AI/openfirma) and
[firma-team](https://github.com/Firma-AI/firma-team) as a dependency (it was
previously vendored as a git submodule). FIR-375 migrated the consumers off the
submodule onto the crate.

The unit of work is still editing the `.proto` files correctly and preserving
wire compatibility — the generated Rust is never hand-edited.

## Build commands

Tasks run through [`just`](https://github.com/casey/just) (recipes in `Justfile`
and `just/`). Run `just` with no arguments to list them.

```bash
just check    # fmt-check + clippy + test + build + audit + deny (CI parity)
just fmt      # dprint fmt — format TOML + Markdown + Rust
just buf lint # lint the .proto wire contract with buf
just package  # verify the crate packages cleanly for crates.io
```

Publishing to crates.io happens from CI (`.github/workflows/publish.yml`) when a
GitHub release is published, via crates.io trusted publishing (OIDC). The release
tag (e.g. `v0.1.0`) must match the version in `Cargo.toml`.

## Wire compatibility rules

The contract is versioned by package (`firma.v1`). When editing:

- Backward-compatible changes add fields with **new tag numbers**.
- Existing field numbers are **never** reused or renumbered.
- A breaking change requires a new package version (`firma.v2`), not a mutation
  of `firma.v1`.

## Architecture (the system the contract describes)

The three proto files map to the three planes of the Firma enforcement system.
The comments inside each file are normative — read them before changing a
message, since they reference the external FEP spec (e.g. FEP §2.3.5 action
classes, [I-N1] policy binding rules).

- `types.proto` — shared message types. The central unit is `ExecutionEnvelope`
  (intent + capability token + metadata), treated as immutable once created.
  Also defines `CapabilityToken`, `PolicyBundle`, `RevocationEvent`,
  `ConnectorResponse`, and the `TokenFormat` / `EnforcementDecision` enums.
- `authority.proto` — `AuthorityService`, the control plane. Issues capability
  tokens (`IssueCapability`) and streams policy bundles (`WatchPolicyBundle`)
  and revocations (`WatchRevocations`) to Sidecars.
- `audit.proto` — `AuditService`, tamper-evident audit log. The Sidecar
  client-streams a signed `ExecutionEvent` after every enforcement decision.

### Roles encoded in the contract

- **Authority** (control plane) defines the permission perimeter at issuance
  time. Contacted only pre-flight and for streaming updates — never on the hot
  path. The perimeter is a ceiling.
- **Sidecar** enforces locally within that perimeter and cannot extend it.
  Two-stage model: Stage 1 capability validation (token parse, signature,
  expiry, revocation bloom filter, < 1ms), Stage 2 Cedar policy enforcement
  (< 200µs). Sole producer of audit events.
- **Connector** applies technical constraints only (rate limits, schema,
  protocol translation). It must not become a second policy engine —
  authorization stays in Cedar / Authority / Sidecar.

### Cross-cutting invariants to preserve when editing

- `ExecutionIntent.action_class` and `resource` drive policy; `raw_transport`
  and `raw_action_ref` are observational only and must not influence policy.
- `ExecutionIntent.params` is a `oneof` — exactly one action kind
  (`HttpParams`, `DbQueryParams`, `ToolUseParams`) per intent. No arbitrary
  key-value blobs; schema validation happens at the proto level.
- `ExecutionEvent` fields before `signature` are covered by an ECDSA signature.
  Adding a field that should be signed means placing it before `signature` in
  intent — but never renumber existing tags (see wire compatibility rules).
