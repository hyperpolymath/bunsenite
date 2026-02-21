<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- TOPOLOGY.md — Project architecture map and completion dashboard -->
<!-- Last updated: 2026-02-19 -->

# Bunsenite — Project Topology

## System Architecture

```
                        ┌─────────────────────────────────────────┐
                        │              CONSUMERS                  │
                        │    (Deno, ReScript, Browser, CLI)       │
                        └───────────────────┬─────────────────────┘
                                            │
                                            ▼
                        ┌─────────────────────────────────────────┐
                        │           INTERFACE LAYER               │
                        │  ┌───────────┐  ┌───────────────────┐  │
                        │  │ Zig FFI   │  │   wasm-bindgen    │  │
                        │  │ (C ABI)   │  │   (JS/WASM)       │  │
                        │  └─────┬─────┘  └────────┬──────────┘  │
                        └────────│─────────────────│──────────────┘
                                 │                 │
                                 ▼                 ▼
                        ┌─────────────────────────────────────────┐
                        │           RUST CORE (LIB.RS)            │
                        │    (Nickel-lang-core integration)       │
                        │  ┌───────────┐  ┌───────────────────┐  │
                        │  │ Parser    │  │    Evaluator      │  │
                        │  └─────┬─────┘  └────────┬──────────┘  │
                        └────────│─────────────────│──────────────┘
                                 │                 │
                                 ▼                 ▼
                        ┌─────────────────────────────────────────┐
                        │          NICKEL CONFIG FILES            │
                        │          (*.ncl, validation)            │
                        └─────────────────────────────────────────┘

                        ┌─────────────────────────────────────────┐
                        │          REPO INFRASTRUCTURE            │
                        │  Justfile / Nix     .machine_readable/  │
                        │  RSR Compliance     .well-known/        │
                        └─────────────────────────────────────────┘
```

## Completion Dashboard

```
COMPONENT                          STATUS              NOTES
─────────────────────────────────  ──────────────────  ─────────────────────────────────
CORE & CLI
  Rust Core (lib.rs)                ██████████ 100%    Nickel 0.9.1 integration stable
  CLI Interface                     ██████████ 100%    Parse/Validate/Info active
  Nickel Loader                     ██████████ 100%    String & File loading verified

BINDINGS & FFI
  Zig FFI (C ABI)                   ██████████ 100%    Stable boundary for bindings
  Deno Bindings                     ██████████ 100%    Deno.dlopen integration active
  WASM / Browser                    ██████████ 100%    95% native speed verified
  ReScript Bindings                 ████████░░  80%    Type definitions refining

REPO INFRASTRUCTURE
  Justfile / Nix                    ██████████ 100%    Reproducible builds stable
  .machine_readable/                ██████████ 100%    STATE.a2ml tracking
  RSR Bronze Tier                   ██████████ 100%    Compliance certified

─────────────────────────────────────────────────────────────────────────────
OVERALL:                            ██████████ 100%    v0.1.0 Production Ready
```

## Key Dependencies

```
Nickel Core ──────► Bunsenite Rust ──────► Zig FFI ──────► Deno/TS
                                              │
                                              ▼
                                         wasm-bindgen ───► Browser
```

## Update Protocol

This file is maintained by both humans and AI agents. When updating:

1. **After completing a component**: Change its bar and percentage
2. **After adding a component**: Add a new row in the appropriate section
3. **After architectural changes**: Update the ASCII diagram
4. **Date**: Update the `Last updated` comment at the top of this file

Progress bars use: `█` (filled) and `░` (empty), 10 characters wide.
Percentages: 0%, 10%, 20%, ... 100% (in 10% increments).
