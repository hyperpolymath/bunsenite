// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//! End-to-end tests for Bunsenite: create → serialize → deserialize → verify round-trip.
//!
//! These tests exercise the full lifecycle of loading a Nickel configuration:
//! starting from a source string or temp file, parsing it via `NickelLoader`,
//! and verifying that the resulting JSON value has the expected shape and
//! content.  At least 10 `#[test]` functions are provided.

use bunsenite::{NickelLoader, NAME, RSR_TIER};
use std::io::Write as _;
use tempfile::NamedTempFile;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Create a `NickelLoader` with verbose mode disabled (default for E2E tests).
fn loader() -> NickelLoader {
    NickelLoader::new()
}

/// Write `content` to a temporary `.ncl` file and return the handle.
/// The file is deleted when the handle is dropped.
fn temp_ncl(content: &str) -> NamedTempFile {
    let mut f = NamedTempFile::new().expect("Failed to create temp file");
    write!(f, "{}", content).expect("Failed to write temp file");
    f
}

// ---------------------------------------------------------------------------
// E2E 1: String source → JSON round-trip — simple record
// ---------------------------------------------------------------------------

/// A simple flat record parsed from a string produces a JSON object with the
/// exact keys and scalar values that were declared.
#[test]
fn e2e_string_round_trip_simple_record() {
    let source = r#"{ project = "bunsenite", version = "1.0.0", stable = true }"#;
    let json = loader()
        .parse_string(source, "simple.ncl")
        .expect("E2E: simple record must parse");

    assert_eq!(json["project"], "bunsenite");
    assert_eq!(json["version"], "1.0.0");
    assert_eq!(json["stable"], true);
}

// ---------------------------------------------------------------------------
// E2E 2: String source → JSON round-trip — numeric fields
// ---------------------------------------------------------------------------

/// Numeric fields survive the parse → JSON conversion without truncation or
/// type-widening.
#[test]
fn e2e_string_round_trip_numeric_fields() {
    let source = r#"{ port = 8080, workers = 4, timeout = 30 }"#;
    let json = loader()
        .parse_string(source, "numeric.ncl")
        .expect("E2E: numeric fields must parse");

    assert_eq!(json["port"], 8080);
    assert_eq!(json["workers"], 4);
    assert_eq!(json["timeout"], 30);
}

// ---------------------------------------------------------------------------
// E2E 3: File source → JSON round-trip
// ---------------------------------------------------------------------------

/// When the same Nickel source is written to a temporary file and loaded via
/// `parse_file`, the resulting JSON is identical to the string-parsed version.
#[test]
fn e2e_file_round_trip_matches_string() {
    let source = r#"{ name = "file-test", enabled = true, count = 7 }"#;
    let tmp = temp_ncl(source);

    let from_file = loader()
        .parse_file(tmp.path())
        .expect("E2E: file load must succeed");
    let from_string = loader()
        .parse_string(source, "ref.ncl")
        .expect("E2E: string load must succeed");

    // Both routes must produce the same JSON structure.
    assert_eq!(from_file, from_string);
}

// ---------------------------------------------------------------------------
// E2E 4: Nested record round-trip
// ---------------------------------------------------------------------------

/// A nested Nickel record is correctly projected into a nested JSON object.
#[test]
fn e2e_nested_record_round_trip() {
    let source = r#"
{
  server = {
    host = "localhost",
    port = 3000,
  },
  database = {
    host = "db.example.com",
    port = 5432,
  },
}
"#;
    let json = loader()
        .parse_string(source, "nested.ncl")
        .expect("E2E: nested record must parse");

    assert_eq!(json["server"]["host"], "localhost");
    assert_eq!(json["server"]["port"], 3000);
    assert_eq!(json["database"]["host"], "db.example.com");
    assert_eq!(json["database"]["port"], 5432);
}

// ---------------------------------------------------------------------------
// E2E 5: Array round-trip
// ---------------------------------------------------------------------------

/// Nickel arrays survive serialisation as JSON arrays with the correct
/// element count and values.
#[test]
fn e2e_array_round_trip() {
    let source = r#"{ tags = ["rust", "nickel", "config"], counts = [1, 2, 3] }"#;
    let json = loader()
        .parse_string(source, "array.ncl")
        .expect("E2E: array record must parse");

    let tags = json["tags"].as_array().expect("tags should be an array");
    assert_eq!(tags.len(), 3);
    assert_eq!(tags[0], "rust");
    assert_eq!(tags[1], "nickel");
    assert_eq!(tags[2], "config");

    let counts = json["counts"].as_array().expect("counts should be an array");
    assert_eq!(counts.len(), 3);
}

// ---------------------------------------------------------------------------
// E2E 6: Arithmetic expression evaluated in config
// ---------------------------------------------------------------------------

/// Nickel supports computed values; the evaluator must reduce the expression
/// before serialisation so that the JSON contains the final numeric result.
#[test]
fn e2e_computed_arithmetic_round_trip() {
    let source = r#"{ total = 100 + 200 + 50, ratio = 6 * 7 }"#;
    let json = loader()
        .parse_string(source, "arith.ncl")
        .expect("E2E: arithmetic config must parse");

    assert_eq!(json["total"], 350);
    assert_eq!(json["ratio"], 42);
}

// ---------------------------------------------------------------------------
// E2E 7: String concatenation evaluated in config
// ---------------------------------------------------------------------------

/// String concatenation via `++` must be reduced by the evaluator; the JSON
/// value must be the fully concatenated string.
#[test]
fn e2e_string_concat_round_trip() {
    let source = r#"{ greeting = "Hello, " ++ "World!", label = "v" ++ "1" ++ "." ++ "0" }"#;
    let json = loader()
        .parse_string(source, "concat.ncl")
        .expect("E2E: string concat config must parse");

    assert_eq!(json["greeting"], "Hello, World!");
    assert_eq!(json["label"], "v1.0");
}

// ---------------------------------------------------------------------------
// E2E 8: Boolean fields are preserved
// ---------------------------------------------------------------------------

/// Boolean `true` and `false` must survive as JSON booleans (not strings or
/// integers).
#[test]
fn e2e_boolean_fields_round_trip() {
    let source = r#"{ on = true, off = false, also_on = true }"#;
    let json = loader()
        .parse_string(source, "bool.ncl")
        .expect("E2E: boolean config must parse");

    assert_eq!(json["on"], true);
    assert_eq!(json["off"], false);
    assert_eq!(json["also_on"], true);
}

// ---------------------------------------------------------------------------
// E2E 9: Multiple independent parse operations on same loader
// ---------------------------------------------------------------------------

/// The `NickelLoader` is stateless between calls; parsing two different configs
/// in sequence on the same instance must produce independent, correct results.
#[test]
fn e2e_multiple_parses_independent() {
    let l = loader();

    let json_a = l
        .parse_string(r#"{ id = 1, name = "alpha" }"#, "a.ncl")
        .expect("E2E: config A must parse");
    let json_b = l
        .parse_string(r#"{ id = 2, name = "beta" }"#, "b.ncl")
        .expect("E2E: config B must parse");

    // Results must be independent.
    assert_eq!(json_a["id"], 1);
    assert_eq!(json_a["name"], "alpha");
    assert_eq!(json_b["id"], 2);
    assert_eq!(json_b["name"], "beta");
    assert_ne!(json_a, json_b);
}

// ---------------------------------------------------------------------------
// E2E 10: validate then parse consistency
// ---------------------------------------------------------------------------

/// For a valid source, `validate` must succeed and `parse_string` must also
/// succeed with a non-null JSON value.
#[test]
fn e2e_validate_then_parse_consistent() {
    let source = r#"{ service = "auth", port = 9000, tls = false }"#;
    let l = loader();

    // Validation must succeed first.
    l.validate(source, "consistent.ncl")
        .expect("E2E: validate must succeed for valid source");

    // Parsing must also succeed and produce a meaningful value.
    let json = l
        .parse_string(source, "consistent.ncl")
        .expect("E2E: parse must succeed for valid source");

    assert_eq!(json["service"], "auth");
    assert_eq!(json["port"], 9000);
    assert_eq!(json["tls"], false);
}

// ---------------------------------------------------------------------------
// E2E 11: file parse → JSON key count matches source
// ---------------------------------------------------------------------------

/// The number of top-level keys in the parsed JSON must match the number of
/// fields declared in the Nickel source record.
#[test]
fn e2e_key_count_matches_source() {
    // Source has exactly 5 top-level fields.
    let source =
        r#"{ a = 1, b = 2, c = 3, d = 4, e = 5 }"#;
    let json = loader()
        .parse_string(source, "keycount.ncl")
        .expect("E2E: key-count config must parse");

    let obj = json.as_object().expect("JSON must be an object");
    assert_eq!(obj.len(), 5, "Exactly 5 keys expected");
}

// ---------------------------------------------------------------------------
// E2E 12: library constants are accessible through public API
// ---------------------------------------------------------------------------

/// The public constants exported by the library (`NAME`, `RSR_TIER`) must
/// match the expected values at runtime, completing the "end-to-end" view
/// that the crate identity survives compilation.
#[test]
fn e2e_library_constants_reachable() {
    assert_eq!(NAME, "bunsenite");
    assert_eq!(RSR_TIER, "bronze");
}
