# Bunsenite

**Nickel configuration file parser with multi-language FFI bindings**

[![RSR Bronze](https://img.shields.io/badge/RSR-Bronze-cd7f32)](https://github.com/hyperpolymath/rsr)
[![TPCF Perimeter 3](https://img.shields.io/badge/TPCF-Perimeter%203-blue)]()
[![License](https://img.shields.io/badge/license-MIT%20%7C%20Palimpsest-green)]()

## Quick Start

```bash
# Install from crates.io
cargo install bunsenite

# Parse a Nickel config
bunsenite parse config.ncl --pretty

# Validate without evaluation
bunsenite validate config.ncl

# Interactive REPL
bunsenite repl

# Watch mode
bunsenite watch config.ncl
```

## Features

| Feature | Description |
|---------|-------------|
| **Parse** | Parse Nickel configs to JSON |
| **Validate** | Validate without full evaluation |
| **Watch** | Auto-reload on file changes |
| **REPL** | Interactive Nickel evaluation |
| **Schema** | JSON Schema validation |
| **FFI** | Stable C ABI via Zig |

## Architecture

```
┌─────────────────────────────────────────┐
│              Consumers                   │
├─────────────┬─────────────┬─────────────┤
│    Deno     │  ReScript   │   Browser   │
│ (Deno FFI)  │  (C FFI)    │   (WASM)    │
└──────┬──────┴──────┬──────┴──────┬──────┘
       │             │             │
       ▼             ▼             ▼
┌─────────────────────────────────────────┐
│         Zig C ABI Layer                 │
│    (Stable interface across Rust        │
│     compiler versions)                   │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│            Rust Core                     │
│                                          │
│  nickel-lang-core 0.9.1                  │
│  miette error diagnostics                │
│  serde serialization                     │
└─────────────────────────────────────────┘
```

## Bindings

### Deno (JavaScript/TypeScript)

```typescript
import { parseNickel, validateNickel } from "./bunsenite.ts";

const config = parseNickel('{ port = 8080 }', "config.ncl");
console.log(config.port); // 8080
```

### ReScript

```rescript
let config = Bunsenite.parse("{ port = 8080 }", "config.ncl")
Js.log(config)
```

### WebAssembly

```javascript
import init, { parse } from './bunsenite.js';

await init();
const config = parse('{ port = 8080 }', 'config.ncl');
```

## RSR Compliance

Bunsenite follows the **Rhodium Standard Repository** (RSR) Bronze tier:

- ✅ **Type Safety**: Compile-time (Rust)
- ✅ **Memory Safety**: Rust ownership model
- ✅ **Offline-First**: No network dependencies
- ✅ **No TypeScript**: Deno FFI uses `.ts` but calls `Deno.dlopen`
- ✅ **No npm/bun**: ReScript `package.json` is for npm publishing only
- ✅ **No Python**: Clean
- ✅ **Justfile**: All builds via Justfile

## Pages

- [[Installation]]
- [[CLI Reference]]
- [[API Reference]]
- [[FFI Guide]]
- [[Examples]]
- [[Contributing]]

## Links

- [GitHub Repository](https://github.com/hyperpolymath/bunsenite)
- [crates.io](https://crates.io/crates/bunsenite)
- [Documentation](https://docs.rs/bunsenite)
