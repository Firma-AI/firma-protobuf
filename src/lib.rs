//! Rust bindings for the Firma `firma.v1` Protobuf/gRPC wire contract.
//!
//! This crate is the published form of the `firma-protobuf` contract: it
//! compiles the `.proto` definitions under `proto/firma/v1/` into Rust types
//! and Tonic service glue. It is the single source of truth for the Authority,
//! Sidecar, and audit wire formats, consumed by
//! [openfirma](https://github.com/Firma-AI/openfirma) and
//! [firma-team](https://github.com/Firma-AI/firma-team).
//!
//! All generated items live under [`v1`]. Both gRPC client and server stubs are
//! generated:
//!
//! - [`v1::authority_service_client`] / [`v1::authority_service_server`]
//! - [`v1::audit_service_client`] / [`v1::audit_service_server`]
//!
//! # Wire compatibility
//!
//! The contract is versioned by package. Backward-compatible changes add fields
//! with new tag numbers; existing field numbers are never reused or renumbered.
//! A breaking change requires a new package version (`firma.v2`).

/// Generated types and Tonic service glue for the `firma.v1` package.
#[allow(
    clippy::default_trait_access,
    clippy::derive_partial_eq_without_eq,
    clippy::doc_markdown,
    clippy::missing_const_for_fn,
    clippy::missing_errors_doc,
    clippy::must_use_candidate,
    clippy::return_self_not_must_use,
    clippy::similar_names,
    clippy::too_long_first_doc_paragraph,
    clippy::too_many_lines,
    clippy::trivially_copy_pass_by_ref,
    clippy::wildcard_imports,
    missing_debug_implementations,
    reason = "Generated Tonic/Prost code is controlled by tonic-prost-build, not hand-written."
)]
pub mod v1 {
    tonic::include_proto!("firma.v1");
}
