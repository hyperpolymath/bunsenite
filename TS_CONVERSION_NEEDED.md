# TypeScript/JavaScript Status

## RSR-Compliant Files (No Conversion Needed)

The following `.ts` files are **Deno-specific FFI bindings** and are RSR-compliant:

- `bindings/deno/bunsenite.ts` - Uses `Deno.dlopen()` for native FFI
- `bindings/deno/example.ts` - Deno FFI usage example

These files use Deno's native FFI system (`Deno.dlopen`), NOT plain TypeScript.
They call into the Zig C ABI layer which wraps the Rust core.

## Architecture

```
Deno Runtime → Deno.dlopen() → Zig FFI (C ABI) → Rust Core
```

## Policy

- **Deno FFI `.ts` files**: ALLOWED (Deno-specific, not plain TypeScript)
- **Plain TypeScript/JavaScript**: NOT ALLOWED
- **New JS/TS modules**: Use ReScript instead
- CI blocks new plain `.ts`/`.js` files (Deno FFI exempted)

## ReScript Bindings

The ReScript bindings at `bindings/rescript/Bunsenite.res` are fully implemented
and provide type-safe access to the Zig FFI layer.
