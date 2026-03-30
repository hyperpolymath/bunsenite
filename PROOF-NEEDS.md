# Proof Requirements

## Current state
- `src/abi/Types.idr` — Nickel parser types
- `src/abi/Layout.idr` — Memory layout
- `src/abi/Foreign.idr` — FFI declarations
- No dangerous patterns in ABI layer
- Claims: type safety, memory safety, "zero `unsafe` blocks"

## What needs proving
- **Parser correctness**: Prove the Nickel parser accepts exactly the Nickel grammar (no over-acceptance of malformed input)
- **Round-trip fidelity**: Prove parse-then-serialize produces semantically equivalent output (no silent data loss)
- **FFI memory safety**: Prove the Zig FFI layer correctly manages ownership across the Rust-Zig-Deno/WASM boundary (no dangling pointers, no double-free)
- **Zero-unsafe claim**: Verify (via tooling or proof) that no `unsafe` blocks exist in the Rust core and that all FFI crossing points are safe

## Recommended prover
- **Idris2** — For parser grammar conformance and FFI boundary properties
- **Lean4** — For algebraic properties of the parse/serialize round-trip if modeled functorially

## Priority
- **MEDIUM** — The "zero unsafe blocks" and type safety claims are strong marketing. Parser correctness matters for any tool in the configuration pipeline, but Bunsenite is not safety-critical infrastructure.

## Template ABI Cleanup (2026-03-29)

Template ABI removed -- was creating false impression of formal verification.
The removed files (Types.idr, Layout.idr, Foreign.idr) contained only RSR template
scaffolding with unresolved {{PROJECT}}/{{AUTHOR}} placeholders and no domain-specific proofs.
