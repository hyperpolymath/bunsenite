// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)

//! Integration tests for Bunsenite — Nickel configuration parser
//!
//! These tests exercise the public API of the bunsenite crate, verifying
//! that configuration parsing, error handling, and metadata constants
//! behave correctly from an external consumer's perspective.

use bunsenite::{NickelLoader, Error, NAME, RSR_TIER, TPCF_PERIMETER, VERSION};

/// Verify that NickelLoader can be constructed with default settings.
#[test]
fn test_loader_construction() {
    let loader = NickelLoader::new();
    // Verbose defaults to false — just ensure construction succeeds
    let _debug_repr = format!("{:?}", loader);
}

/// Verify that NickelLoader supports the builder pattern for verbose mode.
#[test]
fn test_loader_verbose_builder() {
    let loader = NickelLoader::new().with_verbose(true);
    let debug_repr = format!("{:?}", loader);
    assert!(debug_repr.contains("true"), "verbose should be enabled");
}

/// Verify that a simple valid Nickel record parses to JSON containing
/// the expected key-value pairs.
#[test]
fn test_parse_simple_record() {
    let loader = NickelLoader::new();
    let input = r#"{ name = "bunsenite", version = "1.0.0" }"#;
    let result = loader.parse_string(input, "simple.ncl");
    assert!(result.is_ok(), "Simple record should parse: {:?}", result.err());
    let json = result.unwrap();
    assert!(json.to_string().contains("bunsenite"));
    assert!(json.to_string().contains("1.0.0"));
}

/// Verify that numeric values are preserved through parsing.
#[test]
fn test_parse_numeric_values() {
    let loader = NickelLoader::new();
    let input = r#"{ port = 8080, retries = 3 }"#;
    let result = loader.parse_string(input, "numeric.ncl");
    assert!(result.is_ok(), "Numeric record should parse: {:?}", result.err());
    let json = result.unwrap();
    let text = json.to_string();
    assert!(text.contains("8080"), "Should contain port value");
    assert!(text.contains("3"), "Should contain retries value");
}

/// Verify that boolean values round-trip correctly.
#[test]
fn test_parse_boolean_values() {
    let loader = NickelLoader::new();
    let input = r#"{ enabled = true, debug = false }"#;
    let result = loader.parse_string(input, "bool.ncl");
    assert!(result.is_ok(), "Boolean record should parse: {:?}", result.err());
}

/// Verify that empty records parse without error.
#[test]
fn test_parse_empty_record() {
    let loader = NickelLoader::new();
    let input = "{}";
    let result = loader.parse_string(input, "empty.ncl");
    assert!(result.is_ok(), "Empty record should parse: {:?}", result.err());
}

/// Verify that invalid Nickel syntax produces an error, not a panic.
#[test]
fn test_parse_invalid_syntax_returns_error() {
    let loader = NickelLoader::new();
    let input = "this is not valid nickel @@@";
    let result = loader.parse_string(input, "invalid.ncl");
    assert!(result.is_err(), "Invalid syntax should produce an error");
}

/// Verify that the Error type correctly classifies recoverable errors.
#[test]
fn test_error_recoverability() {
    let parse_err = Error::parse_error("test.ncl", "bad syntax");
    assert!(parse_err.is_recoverable(), "Parse errors are recoverable");

    let internal_err = Error::internal("unexpected state");
    assert!(!internal_err.is_recoverable(), "Internal errors are not recoverable");
}

/// Verify crate metadata constants are correctly populated.
#[test]
fn test_crate_metadata() {
    assert_eq!(NAME, "bunsenite");
    assert_eq!(RSR_TIER, "bronze");
    assert_eq!(TPCF_PERIMETER, 3);
    // VERSION should be semver
    let parts: Vec<&str> = VERSION.split('.').collect();
    assert_eq!(parts.len(), 3, "VERSION should be semver x.y.z");
}
