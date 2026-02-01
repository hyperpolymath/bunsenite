# Bunsenite Zig FFI Layer
image:https://img.shields.io/badge/License-PMPL--1.0-blue.svg[License: PMPL-1.0,link="https://github.com/hyperpolymath/palimpsest-license"]



This directory contains the Zig wrapper that provides a stable C ABI for the Rust core library.

## Purpose

The Zig layer isolates consumers (Deno, ReScript) from Rust ABI changes across compiler versions, providing:

- **Stable C ABI**: Guaranteed binary compatibility
- **Cross-platform**: Builds for Linux, macOS, Windows
- **Small overhead**: Thin wrapper, minimal performance impact

## Architecture

```
Deno/ReScript → Zig (stable C ABI) → Rust (native)
```

## Prerequisites

1. **Rust toolchain**: `rustup install stable`
2. **Zig compiler**: `zig version` (0.11.0 or later recommended)

## Building

```bash
# Build Rust library first
cargo build --release

# Build Zig FFI layer
cd zig
zig build -Doptimize=ReleaseFast
```

Output libraries:
- Linux: `zig-out/lib/libbunsenite.so`
- macOS: `zig-out/lib/libbunsenite.dylib`
- Windows: `zig-out/lib/bunsenite.dll`

## Exported Symbols

| Symbol | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `parse_nickel` | `(source, name)` | `char*` | Parse Nickel to JSON |
| `validate_nickel` | `(source, name)` | `int` | Validate config (0=ok) |
| `free_string` | `(ptr)` | `void` | Free allocated string |
| `version` | `()` | `char*` | Library version |
| `rsr_tier` | `()` | `char*` | RSR compliance tier |
| `tpcf_perimeter` | `()` | `u8` | TPCF perimeter number |

## Testing

```bash
# Run Zig tests (requires Rust library)
cargo build --release
cd zig && zig build test
```

## Integration

### Deno

The Zig library is used by `bindings/deno/bunsenite.ts` via `Deno.dlopen()`.

### ReScript

The Zig library is used by `bindings/rescript/Bunsenite.res` via C FFI.

## RSR Compliance

This FFI layer maintains RSR Bronze tier compliance:
- Type safety through Zig's type system
- Memory safety with explicit allocation/deallocation
- No network dependencies
