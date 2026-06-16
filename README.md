# firma-protobuf

Shared Protobuf/gRPC wire contract for the Firma stack.

This repository holds **only** the `.proto` definitions. It is the single source
of truth for the Authority, Sidecar, and audit wire formats, consumed as a git
submodule by both [openfirma](https://github.com/Firma-AI/openfirma) and
[firma-team](https://github.com/Firma-AI/firma-team). Each consumer compiles
these definitions into language bindings on its own (for Rust, via
`tonic-prost-build` pointing at `proto/`).

## Layout

```text
proto/
└── firma/
    └── v1/
        ├── audit.proto      # audit event streaming
        ├── authority.proto  # AuthorityService: issuance, policy, revocations
        └── types.proto      # shared message types
```

## Usage as a submodule

```bash
git submodule add git@github.com:Firma-AI/firma-protobuf.git firma-protobuf
```

In a Rust `build.rs`, point the compiler at the submodule's `proto/` directory:

```rust
tonic_prost_build::configure().compile_protos(
    &["firma-protobuf/proto/firma/v1/authority.proto"],
    &["firma-protobuf/proto"],
)?;
```

## Versioning

The wire contract is versioned by package (`firma.v1`). Backward-compatible
changes add fields with new tag numbers; existing field numbers are never
reused or renumbered.
