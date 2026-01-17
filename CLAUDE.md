# Bunsenite Project

## Project Overview

Bunsenite is a Nickel configuration file parser with multi-language FFI bindings. It provides a Rust core library with a Zig C ABI layer that enables bindings for Deno (JavaScript/TypeScript), ReScript, and WebAssembly for browser and universal use.

**Status**: v1.0.0 - Production ready
**Repository**: https://github.com/hyperpolymath/bunsenite (mirror: GitLab)
**License**: Dual PMPL-1.0 + Palimpsest 0.8

## Project Structure

```
bunsenite/
├── src/
│   ├── lib.rs              # Main library entry point
│   ├── main.rs             # CLI with parse, validate, watch, repl, schema
│   ├── loader.rs           # Nickel file loader (nickel-lang-core 0.9.1 API)
│   └── wasm.rs             # WebAssembly bindings
├── zig/
│   └── bunsenite.zig       # Zig C ABI layer (stable FFI interface)
├── bindings/
│   ├── deno/               # Deno FFI bindings (Deno.dlopen)
│   ├── rescript/           # ReScript C FFI bindings
│   └── wasm/               # WASM build target
├── examples/
│   ├── config.ncl          # Full configuration example
│   └── simple.ncl          # Minimal example
├── packaging/              # Package manager configs (AUR, deb, rpm, etc.)
├── .github/workflows/      # CI/CD (release, RSR antipattern check)
├── Cargo.toml              # Rust dependencies
├── Justfile                # Build commands (45+ recipes)
├── CLAUDE.md               # This file - AI assistant context
├── STATE.scm               # Project state checkpoint
└── LICENSE                 # PMPL-1.0 + Palimpsest dual license
```

## Technology Stack

**Core:**
- Language: Rust (2021 edition, 1.70+)
- Parser: nickel-lang-core 0.9.1
- Error handling: miette 7.0 (fancy diagnostics)
- Serialization: serde, serde_json

**FFI Layer:**
- C ABI: Zig (provides stable interface isolating consumers from Rust ABI changes)

**Bindings:**
- Deno: TypeScript with Deno.dlopen for native FFI (NOT plain TypeScript)
- ReScript: Direct C FFI bindings
- WebAssembly: wasm-bindgen for browser/universal deployment

**CLI Features:**
- `parse` - Parse and evaluate Nickel config to JSON
- `validate` - Validate config without evaluation
- `watch` - Watch mode with notify crate
- `repl` - Interactive REPL with rustyline
- `schema` - JSON Schema validation
- `info` - Library and compliance info

**Build Tools:**
- Build system: Cargo + Justfile (no shell scripts)
- WASM tooling: wasm-pack

## RSR Compliance

**Tier**: Bronze
**TPCF Perimeter**: 3 (Community Sandbox)

**Requirements Met:**
- Type Safety: Compile-time (Rust)
- Memory Safety: Rust ownership model
- Offline-First: No network dependencies
- No Plain TypeScript: Deno FFI uses .ts but calls Deno.dlopen
- No npm/bun: ReScript package.json is for npm publishing of compiled output
- No Python: Clean
- No Shell Scripts: All builds via Justfile

## Development Setup

### Prerequisites

- Rust toolchain (2021 edition, 1.70+)
- Zig compiler (for C ABI layer)
- just command runner (`cargo install just`)
- Optional: wasm-pack for WebAssembly builds
- Optional: Deno runtime for testing Deno bindings

### Quick Start

```bash
# Clone and build
git clone https://github.com/hyperpolymath/bunsenite.git
cd bunsenite
just all

# Run CLI
cargo run --release -- parse examples/config.ncl --pretty

# Run with all features
cargo run --release --all-features -- repl
```

### Justfile Recipes

```bash
just                    # List all recipes
just all               # Build all targets
just build             # Build release binaries
just wasm              # Build WebAssembly
just test              # Run all tests
just check             # Run all quality checks
just rsr-check         # Verify RSR Bronze compliance
just rsr-report        # Generate compliance report
```

## Code Conventions

### Style
- Rust standard formatting: `cargo fmt`
- Lint with: `cargo clippy`
- Use explicit error types (anyhow for apps, thiserror for libs)
- Document public APIs with `///` doc comments

### Testing
- All tests must pass before commit
- Run: `cargo test`
- Coverage: Unit tests + doc tests

## Architecture

### Data Flow

```
┌─────────────────────────────────────────────────┐
│                   Consumers                     │
├───────────────┬───────────────┬─────────────────┤
│     Deno      │   ReScript    │     Browser     │
│  (Deno FFI)   │   (C FFI)     │     (WASM)      │
└───────┬───────┴───────┬───────┴────────┬────────┘
        │               │                │
        ▼               ▼                ▼
  ┌──────────┐   ┌──────────┐    ┌──────────────┐
  │ Zig FFI  │   │ Zig FFI  │    │ wasm-bindgen │
  │ (C ABI)  │   │ (C ABI)  │    │              │
  └─────┬────┘   └─────┬────┘    └──────┬───────┘
        │              │                 │
        └──────────────┴─────────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │   Rust Core     │
              │                 │
              │ nickel-lang-core│
              │     0.9.1       │
              │                 │
              │ miette errors   │
              └─────────────────┘
```

### Key Components

1. **src/lib.rs**: Public API entry point
2. **src/loader.rs**: Nickel parser using nickel-lang-core 0.9.1
3. **src/main.rs**: CLI with parse, validate, watch, repl, schema commands
4. **src/wasm.rs**: WebAssembly bindings
5. **zig/bunsenite.zig**: Stable C ABI wrapper
6. **bindings/deno/**: Deno FFI (Deno.dlopen)
7. **bindings/rescript/**: ReScript C FFI

## Critical Design Decisions

**REQUIRED Technologies:**
- Rust core
- Zig C ABI layer (stable FFI)
- Deno bindings (Deno.dlopen, NOT plain TypeScript)
- ReScript bindings (via C FFI)
- WebAssembly bindings
- Justfile for builds

**NOT ALLOWED (RSR Compliance):**
- Plain TypeScript (Deno .ts files are FFI, not compiled TS)
- Shell scripts (use Justfile)
- npm/bun for primary build (package.json for ReScript npm publishing only)
- bun:ffi (ALWAYS use Deno.dlopen instead)
- ffi-napi / Node.js FFI (ALWAYS use Deno.dlopen instead)
- Python (except SaltStack support contexts)

**IMPORTANT:** If JavaScript FFI is needed, ALWAYS use Deno's Deno.dlopen.
Never create bun:ffi or node ffi-napi files. This is a strict RSR requirement.

**Future:**
- TUI: Ada/SPARK (planned for v2.0)
- LSP: tower-lsp (research phase)

## API Compatibility Notes

**nickel-lang-core 0.9.1:**
1. `Program::new_from_source()` requires trace parameter: `std::io::sink()`
2. `eval_full()` takes no arguments
3. Manual error conversion via `serde_json::to_value()`
4. NO `into_diagnostics()` method

See `src/loader.rs` for correct usage patterns.

## Notes for AI Assistants

### Project State

- **Version**: 1.0.0 (production ready)
- **All features complete**: CLI, FFI, bindings, watch, REPL, schema
- **RSR Bronze compliant**
- **TPCF Perimeter 3**

### When Making Changes

- Use Justfile commands, NOT shell scripts
- Run `cargo test` before commit
- Run `cargo fmt` and `cargo clippy`
- Update STATE.scm if project state changes
- Follow RSR guidelines (no TS, no npm, no Python)

### State File

The `STATE.scm` file tracks project state in machine-readable Scheme format. Update it when:
- Completing major features
- Changing project phase
- Modifying architecture

### User Preferences

- Deno preferred over npm/bun
- ReScript preferred over TypeScript
- Ada/SPARK for TUI (future)
- No shell scripts (Justfile only)
- Offline-first design
- Emotional safety considerations

## CI/CD Notes

**Build Times (per platform):**
- Rust compilation: ~7-10 minutes (with `--features full`)
- Zig FFI build: ~30 seconds
- Packaging/upload: ~1 minute
- Total: ~10-15 minutes per platform

**Important:** Build times do NOT affect end users - they download pre-built binaries.
These times are CI/CD only (release workflow on tag push).

**Optimization opportunities:**
- Cargo caching is configured but GitHub's cache service can be unreliable
- Consider reducing targets if not all platforms are needed
- Cross-compilation (aarch64-linux) uses Docker containers and is slower

**Zig FFI Status by Platform:**
- Linux x86_64: Full Zig FFI support
- macOS (both archs): Full Zig FFI support
- Linux aarch64: Rust binary only (cross-compilation, Zig FFI skipped)
- Windows: Rust binary only (Zig FFI skipped, needs import library setup)

## Changelog

- **2025-12-12**: Updated to v1.0.0
  - All features complete
  - Zig FFI layer implemented
  - Watch, REPL, schema commands
  - miette error diagnostics
  - RSR Bronze compliant

- **2025-11-21**: Initial CLAUDE.md (v0.1.0)

---

**Note**: Keep STATE.scm and CLAUDE.md updated to help AI assistants and developers understand project state quickly.
