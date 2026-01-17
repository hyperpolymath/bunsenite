# Proven Library Integration Plan

This document outlines how the [proven](https://github.com/hyperpolymath/proven) library's formally verified modules integrate with Bunsenite.

## Applicable Modules

### High Priority

| Module | Use Case | Formal Guarantee |
|--------|----------|------------------|
| `SafeSchema` | Nickel config validation | Type-safe configurations |
| `SafeFFI` | FFI boundary safety | ABI contract verification |
| `SafeBuffer` | Config parsing buffer | Bounded memory usage |

### Medium Priority

| Module | Use Case | Formal Guarantee |
|--------|----------|------------------|
| `SafeString` | Config interpolation | Injection prevention |
| `SafeTree` | Config tree navigation | ValidPath proofs |
| `SafeResource` | File handle lifecycle | Valid state transitions |

## Integration Points

### 1. Config Schema Validation (SafeSchema)

```nickel
# Nickel config
{
  name = "my-app",
  port = 8080,
  features = ["auth", "logging"]
}
```

```
parse → SafeSchema.validate → typed NickelConfig
```

SafeSchema ensures:
- Required fields are present
- Field types match declarations
- Contract constraints are satisfied

### 2. FFI Boundary Safety (SafeFFI)

Bunsenite's C ABI boundary is where safety is most critical:

```
Rust → SafeFFI.marshal → C ABI → SafeFFI.unmarshal → Deno/ReScript
```

SafeFFI guarantees:
- Memory ownership is correctly transferred
- Buffers are correctly sized and aligned
- Error codes are properly propagated
- No use-after-free or double-free

### 3. Parsing Buffer Management (SafeBuffer)

```
config_file → SafeBuffer.BoundedBuffer → parse → result
```

Prevents:
- Stack overflow on deeply nested configs
- OOM on maliciously large inputs
- Buffer overflows in string handling

## FFI Contract Proofs

Bunsenite's C ABI can be formally specified:

```c
// include/bebop_v_ffi.h
struct BunseniteResult {
    uint32_t status;     // SafeFFI.ResultCode
    void* data;          // SafeFFI.OwnedPtr
    size_t len;          // SafeFFI.BoundedSize
};
```

SafeFFI proves:
- `status == OK` ⟹ `data != NULL ∧ len > 0`
- `status == ERROR` ⟹ `data` contains error message
- Caller owns `data` and must free it

## Language Binding Integration

| Binding | FFI Layer | proven Module |
|---------|-----------|---------------|
| Deno | Deno.dlopen | SafeFFI |
| ReScript | External FFI | SafeFFI |
| WASM | Wasm bindgen | SafeBuffer |

## Implementation Notes

For Rust core integration:

```rust
// src/lib.rs
#[cfg(feature = "proven")]
mod proven_bindings {
    // SafeSchema validation before returning to FFI
    pub fn validate_config(input: &str) -> Result<NickelValue, Error> {
        SafeSchema::validate(input)?
    }
}
```

## Status

- [ ] Add SafeSchema for Nickel config validation
- [ ] Integrate SafeFFI for ABI contract verification
- [ ] Implement SafeBuffer for bounded parsing
- [ ] Generate proofs for C ABI contract
