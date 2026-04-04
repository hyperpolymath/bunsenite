// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//! Aspect tests for Bunsenite — robustness, error handling, and API contracts.
//!
//! Tests cover:
//! - Malformed / corrupt input is rejected gracefully (no panic, proper `Err`).
//! - Extremely large inputs are handled without panic.
//! - All public API entry points accept valid inputs without panicking.
//! - Error types carry expected diagnostic information.
//! - The `validate` path and the `parse` path agree on what is valid.

use bunsenite::{Error, NickelLoader};

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

fn loader() -> NickelLoader {
    NickelLoader::new()
}

// ---------------------------------------------------------------------------
// Aspect: Malformed input is rejected gracefully — no panic
// ---------------------------------------------------------------------------

/// Completely empty input must not panic.  It should either parse (producing
/// an empty result) or return an error; the test only asserts the absence of
/// a panic.
#[test]
fn aspect_empty_input_no_panic() {
    let result = loader().parse_string("", "empty.ncl");
    // No assertion on Ok/Err — just verifying no panic.
    let _ = result;
}

/// A string of random punctuation that cannot be valid Nickel must produce an
/// `Err` without panicking.
#[test]
fn aspect_garbage_input_returns_error() {
    let result = loader().parse_string("@@@ !! ??? %%% ###", "garbage.ncl");
    assert!(
        result.is_err(),
        "Garbage input should return an error, not Ok"
    );
}

/// An unclosed brace is syntactically invalid; the parser must return an error
/// rather than panicking or hanging.
#[test]
fn aspect_unclosed_brace_returns_error() {
    let result = loader().parse_string("{ name = \"open\"", "unclosed.ncl");
    assert!(result.is_err(), "Unclosed brace must be rejected");
}

/// A record field with no value (`{ foo = }`) is invalid Nickel syntax; the
/// parser must return an error.
#[test]
fn aspect_field_missing_value_returns_error() {
    let result = loader().parse_string("{ foo = }", "bad_field.ncl");
    assert!(result.is_err(), "Missing field value must be rejected");
}

/// A stray `=` with no surrounding structure is not valid Nickel.
#[test]
fn aspect_lone_equals_returns_error() {
    let result = loader().parse_string("=", "lone_eq.ncl");
    assert!(result.is_err(), "A lone '=' must be rejected");
}

/// Invalid Unicode escape sequences or non-UTF-8-safe byte patterns must not
/// cause a panic.  Using a replacement-character string as a soft approximation.
#[test]
fn aspect_unicode_replacement_no_panic() {
    // U+FFFD is the Unicode replacement character — valid UTF-8, but
    // unlikely to form valid Nickel syntax.
    let weird = "\u{FFFD}\u{FFFD}\u{FFFD}";
    let result = loader().parse_string(weird, "unicode.ncl");
    let _ = result; // Must not panic.
}

/// A very deeply nested Nickel record should not cause a stack overflow.
/// We use a moderate depth (50 levels) to keep the test fast while still
/// exercising the recursive parser.
#[test]
fn aspect_moderately_deep_nesting_no_panic() {
    // Build "{ a = { a = { … = 42 } … } }" with 50 levels.
    let depth = 50usize;
    let open: String = "{ a = ".repeat(depth);
    let mid = "42";
    let close: String = " }".repeat(depth);
    let source = format!("{open}{mid}{close}");

    let result = loader().parse_string(&source, "deep.ncl");
    // Not requiring Ok — some dialects may limit nesting — but must not panic.
    let _ = result;
}

// ---------------------------------------------------------------------------
// Aspect: Large inputs are handled without panic
// ---------------------------------------------------------------------------

/// A configuration with a large number of fields (1000) must be processed
/// without panicking.  Whether it succeeds or fails is secondary; the
/// important guarantee is no crash.
#[test]
fn aspect_large_flat_record_no_panic() {
    let fields: String = (0..1000)
        .map(|i| format!("  field_{i} = {i},\n"))
        .collect();
    let source = format!("{{\n{fields}}}");
    let result = loader().parse_string(&source, "large.ncl");
    // Must not panic.  Nickel may or may not handle 1000 fields; we only
    // require graceful behaviour.
    let _ = result;
}

/// A single string field with a very long value (100 KiB) must not cause a
/// panic.
#[test]
fn aspect_long_string_value_no_panic() {
    let long_val = "x".repeat(100_000);
    let source = format!(r#"{{ data = "{long_val}" }}"#);
    let result = loader().parse_string(&source, "longval.ncl");
    let _ = result;
}

// ---------------------------------------------------------------------------
// Aspect: Public API accepts valid inputs without panicking
// ---------------------------------------------------------------------------

/// `NickelLoader::new()` must never panic.
#[test]
fn aspect_loader_construction_never_panics() {
    let _l = NickelLoader::new();
}

/// `NickelLoader::with_verbose(true)` must not panic.
#[test]
fn aspect_verbose_builder_never_panics() {
    let _l = NickelLoader::new().with_verbose(true);
    let _l2 = NickelLoader::new().with_verbose(false);
}

/// `parse` (alias for `parse_string`) must not panic on valid input.
#[test]
fn aspect_parse_alias_no_panic_valid() {
    let result = loader().parse(r#"{ ok = true }"#, "alias.ncl");
    assert!(result.is_ok(), "parse() alias must succeed on valid input");
}

/// `validate` must not panic on valid or invalid input.
#[test]
fn aspect_validate_no_panic_on_valid() {
    let result = loader().validate(r#"{ x = 1 }"#, "valid.ncl");
    assert!(result.is_ok());
}

#[test]
fn aspect_validate_no_panic_on_invalid() {
    // Should return Err, not panic.
    let result = loader().validate("{ broken =", "broken.ncl");
    assert!(result.is_err());
}

/// `parse_file` with a nonexistent path must return an `Err`, not panic.
#[test]
fn aspect_parse_file_nonexistent_returns_error() {
    let result = loader().parse_file("/nonexistent/path/does_not_exist.ncl");
    assert!(
        result.is_err(),
        "Nonexistent file path must produce an error"
    );
}

// ---------------------------------------------------------------------------
// Aspect: Error type invariants
// ---------------------------------------------------------------------------

/// A `ParseError` produced via the public constructor must be recoverable.
#[test]
fn aspect_parse_error_is_recoverable() {
    let err = Error::parse_error("f.ncl", "syntax error");
    assert!(
        err.is_recoverable(),
        "ParseError should be classified as recoverable"
    );
}

/// An `Internal` error must be classified as non-recoverable.
#[test]
fn aspect_internal_error_not_recoverable() {
    let err = Error::internal("bug");
    assert!(
        !err.is_recoverable(),
        "Internal error should not be recoverable"
    );
}

/// The `message()` accessor must return the message that was passed into the
/// constructor without transformation.
#[test]
fn aspect_error_message_accessor_round_trips() {
    let msg = "custom diagnostic text";
    let err = Error::parse_error("test.ncl", msg);
    assert_eq!(err.message(), msg, "message() should return the original message verbatim");
}

/// A `SerializationError` must be non-recoverable (it indicates an internal
/// invariant violation, not a user mistake).
#[test]
fn aspect_serialization_error_not_recoverable() {
    let err = Error::serialization_error("cannot convert");
    assert!(
        !err.is_recoverable(),
        "SerializationError should not be recoverable"
    );
}

// ---------------------------------------------------------------------------
// Aspect: validate / parse agreement
// ---------------------------------------------------------------------------

/// For every valid Nickel snippet, `validate` succeeding must imply that
/// `parse_string` also succeeds (no divergence between the two code paths
/// for syntactically valid input).
#[test]
fn aspect_validate_implies_parse_for_valid_inputs() {
    let valid_inputs = [
        r#"{ a = 1 }"#,
        r#"{ name = "test", flag = true }"#,
        r#"{ nested = { x = 42 } }"#,
        r#"{ items = [1, 2, 3] }"#,
    ];

    let l = loader();
    for src in valid_inputs {
        if l.validate(src, "t.ncl").is_ok() {
            let parse_result = l.parse_string(src, "t.ncl");
            assert!(
                parse_result.is_ok(),
                "validate() succeeded but parse_string() failed for: {src}"
            );
        }
    }
}
