// Bunsenite Zig FFI Layer
//
// This module provides a stable C ABI wrapper around the Rust core library.
// It isolates consumers (Deno, ReScript) from Rust ABI changes across versions.
//
// Architecture:
//   Deno/ReScript → Zig (stable C ABI) → Rust (native)
//
// Build:
//   zig build -Doptimize=ReleaseFast
//
// The resulting shared library exports these symbols:
//   - parse_nickel(source, name) -> char*
//   - validate_nickel(source, name) -> int
//   - free_string(ptr) -> void
//   - version() -> char*
//   - rsr_tier() -> char*
//   - tpcf_perimeter() -> u8

const std = @import("std");

// Import Rust FFI functions via C ABI
// These are defined in src/ffi.rs with #[no_mangle] pub extern "C"
extern fn bunsenite_parse(source: [*:0]const u8, name: [*:0]const u8) callconv(.C) ?[*:0]u8;
extern fn bunsenite_validate(source: [*:0]const u8, name: [*:0]const u8) callconv(.C) i32;
extern fn bunsenite_free_string(ptr: ?[*:0]u8) callconv(.C) void;
extern fn bunsenite_version() callconv(.C) [*:0]const u8;
extern fn bunsenite_rsr_tier() callconv(.C) [*:0]const u8;
extern fn bunsenite_tpcf_perimeter() callconv(.C) u8;

// Re-export with stable, consumer-friendly names
// These match the symbols expected by bindings/deno/bunsenite.ts

/// Parse a Nickel configuration string and return JSON
///
/// Parameters:
///   source: Null-terminated Nickel source code
///   name: Null-terminated filename (for error messages)
///
/// Returns:
///   Pointer to JSON string on success, null on failure
///   MUST be freed with free_string()
pub export fn parse_nickel(source: [*:0]const u8, name: [*:0]const u8) callconv(.C) ?[*:0]u8 {
    return bunsenite_parse(source, name);
}

/// Validate a Nickel configuration without evaluating
///
/// Parameters:
///   source: Null-terminated Nickel source code
///   name: Null-terminated filename (for error messages)
///
/// Returns:
///   0 on success (valid)
///   1 on validation error
///   -1 on invalid input
pub export fn validate_nickel(source: [*:0]const u8, name: [*:0]const u8) callconv(.C) i32 {
    return bunsenite_validate(source, name);
}

/// Free a string allocated by parse_nickel
///
/// Parameters:
///   ptr: Pointer returned by parse_nickel (may be null)
pub export fn free_string(ptr: ?[*:0]u8) callconv(.C) void {
    bunsenite_free_string(ptr);
}

/// Get the library version
///
/// Returns:
///   Static string pointer (do NOT free)
pub export fn version() callconv(.C) [*:0]const u8 {
    return bunsenite_version();
}

/// Get the RSR compliance tier
///
/// Returns:
///   Static string pointer (do NOT free)
pub export fn rsr_tier() callconv(.C) [*:0]const u8 {
    return bunsenite_rsr_tier();
}

/// Get the TPCF perimeter number
///
/// Returns:
///   3 for Community Sandbox
pub export fn tpcf_perimeter() callconv(.C) u8 {
    return bunsenite_tpcf_perimeter();
}

// Test the FFI layer
test "version returns non-empty string" {
    const ver = version();
    try std.testing.expect(ver[0] != 0);
}

test "rsr_tier returns bronze" {
    const tier = rsr_tier();
    const expected = "bronze";
    var i: usize = 0;
    while (i < expected.len) : (i += 1) {
        try std.testing.expectEqual(expected[i], tier[i]);
    }
}

test "tpcf_perimeter returns 3" {
    try std.testing.expectEqual(@as(u8, 3), tpcf_perimeter());
}
