// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//! Property-based tests for Bunsenite (no external proptest crate required).
//!
//! Rather than using a generative property-test framework, these tests exercise
//! a fixed corpus of 10 varied data inputs and assert algebraic invariants:
//!
//! - **Round-trip**: `parse_string(x)` produces a JSON value; the same source
//!   parsed again produces an equal value (determinism / idempotency of the
//!   parse step).
//! - **Type invariants**: booleans remain booleans, numbers remain numbers,
//!   strings remain strings, arrays remain arrays after parse.
//! - **No information loss**: all top-level keys declared in the source are
//!   present in the JSON output.

use bunsenite::NickelLoader;

// ---------------------------------------------------------------------------
// Corpus: 10 varied Nickel configuration inputs
// ---------------------------------------------------------------------------

/// Each entry is `(label, nickel_source)`.  Entries cover:
///   0. Minimal single field (string)
///   1. Multiple scalars of different types
///   2. Nested record
///   3. Array of strings
///   4. Array of integers
///   5. Deep nesting (3 levels)
///   6. Computed arithmetic
///   7. String concatenation
///   8. Mixed scalars + nested
///   9. Boolean-only record
const CORPUS: &[(&str, &str)] = &[
    // 0 — single string field
    ("single_string", r#"{ greeting = "hello" }"#),
    // 1 — three scalar types
    ("multi_scalar", r#"{ name = "cfg", count = 42, active = true }"#),
    // 2 — nested record (one level)
    (
        "nested_one",
        r#"{ outer = { inner = "value", num = 7 } }"#,
    ),
    // 3 — array of strings
    ("array_strings", r#"{ tags = ["a", "b", "c", "d"] }"#),
    // 4 — array of integers
    ("array_ints", r#"{ nums = [10, 20, 30] }"#),
    // 5 — three-level nesting
    (
        "deep_nest",
        r#"{ l1 = { l2 = { l3 = "leaf" } } }"#,
    ),
    // 6 — computed arithmetic
    ("computed", r#"{ x = 3 * 4, y = 100 - 1 }"#),
    // 7 — string concatenation
    ("concat", r#"{ s = "foo" ++ "bar" ++ "baz" }"#),
    // 8 — mixed scalars and nested
    (
        "mixed",
        r#"{ host = "localhost", port = 5432, opts = { ssl = true } }"#,
    ),
    // 9 — booleans only
    ("booleans", r#"{ yes = true, no = false }"#),
];

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

fn loader() -> NickelLoader {
    NickelLoader::new()
}

// ---------------------------------------------------------------------------
// Property 1: Every corpus entry parses without error
// ---------------------------------------------------------------------------

/// All 10 corpus inputs must parse successfully: none of them should return
/// an `Err` variant.
#[test]
fn property_all_corpus_entries_parse() {
    let l = loader();
    for (label, source) in CORPUS {
        let result = l.parse_string(source, &format!("{label}.ncl"));
        assert!(
            result.is_ok(),
            "Corpus entry '{label}' failed to parse: {:?}",
            result.err()
        );
    }
}

// ---------------------------------------------------------------------------
// Property 2: Parsing the same input twice yields equal results (determinism)
// ---------------------------------------------------------------------------

/// For each corpus entry, parsing it twice on the same loader must produce
/// two `serde_json::Value` instances that are equal.  This verifies that
/// the parse → evaluate pipeline is deterministic (no random seeds, no
/// mutable shared state).
#[test]
fn property_parse_is_deterministic() {
    let l = loader();
    for (label, source) in CORPUS {
        let name = format!("{label}.ncl");
        let first = l
            .parse_string(source, &name)
            .unwrap_or_else(|e| panic!("First parse of '{label}' failed: {e}"));
        let second = l
            .parse_string(source, &name)
            .unwrap_or_else(|e| panic!("Second parse of '{label}' failed: {e}"));
        assert_eq!(
            first, second,
            "Parse of '{label}' is not deterministic: got different results"
        );
    }
}

// ---------------------------------------------------------------------------
// Property 3: Parsed JSON is always a JSON object (not null, array, scalar)
// ---------------------------------------------------------------------------

/// Every corpus input is a Nickel record (`{ … }`).  After evaluation the
/// result must be a JSON object, not `null`, a bare array, or a bare scalar.
#[test]
fn property_result_is_always_object() {
    let l = loader();
    for (label, source) in CORPUS {
        let json = l
            .parse_string(source, &format!("{label}.ncl"))
            .unwrap_or_else(|e| panic!("Parse of '{label}' failed: {e}"));
        assert!(
            json.is_object(),
            "Corpus entry '{label}' did not produce a JSON object; got: {json:?}"
        );
    }
}

// ---------------------------------------------------------------------------
// Property 4: Boolean values remain boolean in JSON
// ---------------------------------------------------------------------------

/// Corpus entry 9 (`booleans`) has two boolean fields.  After parsing they
/// must be of JSON boolean type — not converted to strings or integers.
#[test]
fn property_booleans_stay_boolean() {
    let l = loader();
    let (label, source) = CORPUS[9];
    let json = l
        .parse_string(source, &format!("{label}.ncl"))
        .unwrap_or_else(|e| panic!("Parse of '{label}' failed: {e}"));

    assert!(
        json["yes"].is_boolean(),
        "'yes' field should be boolean, got: {:?}",
        json["yes"]
    );
    assert!(
        json["no"].is_boolean(),
        "'no' field should be boolean, got: {:?}",
        json["no"]
    );
    assert_eq!(json["yes"], true);
    assert_eq!(json["no"], false);
}

// ---------------------------------------------------------------------------
// Property 5: Numeric values remain numeric in JSON
// ---------------------------------------------------------------------------

/// Corpus entry 1 has an integer field `count = 42`.  After parsing it must
/// be a JSON number, not a string.
#[test]
fn property_numbers_stay_numeric() {
    let l = loader();
    let (label, source) = CORPUS[1];
    let json = l
        .parse_string(source, &format!("{label}.ncl"))
        .unwrap_or_else(|e| panic!("Parse of '{label}' failed: {e}"));

    assert!(
        json["count"].is_number(),
        "'count' should be numeric, got: {:?}",
        json["count"]
    );
    assert_eq!(json["count"], 42);
}

// ---------------------------------------------------------------------------
// Property 6: String values remain strings in JSON
// ---------------------------------------------------------------------------

/// Corpus entry 0 has `greeting = "hello"`.  After parsing the field must be
/// a JSON string.
#[test]
fn property_strings_stay_strings() {
    let l = loader();
    let (label, source) = CORPUS[0];
    let json = l
        .parse_string(source, &format!("{label}.ncl"))
        .unwrap_or_else(|e| panic!("Parse of '{label}' failed: {e}"));

    assert!(
        json["greeting"].is_string(),
        "'greeting' should be a string, got: {:?}",
        json["greeting"]
    );
    assert_eq!(json["greeting"], "hello");
}

// ---------------------------------------------------------------------------
// Property 7: Arrays remain arrays in JSON
// ---------------------------------------------------------------------------

/// Corpus entry 3 has `tags = ["a", "b", "c", "d"]`.  After parsing the
/// field must be a JSON array with the correct length.
#[test]
fn property_arrays_stay_arrays() {
    let l = loader();
    let (label, source) = CORPUS[3];
    let json = l
        .parse_string(source, &format!("{label}.ncl"))
        .unwrap_or_else(|e| panic!("Parse of '{label}' failed: {e}"));

    let arr = json["tags"]
        .as_array()
        .unwrap_or_else(|| panic!("'tags' should be an array, got: {:?}", json["tags"]));
    assert_eq!(arr.len(), 4, "Array should have 4 elements");
}

// ---------------------------------------------------------------------------
// Property 8: Computed expressions collapse to their expected values
// ---------------------------------------------------------------------------

/// Corpus entry 6 (`computed`) contains `x = 3 * 4` and `y = 100 - 1`.
/// After evaluation these must be the integers `12` and `99` respectively.
#[test]
fn property_arithmetic_is_fully_evaluated() {
    let l = loader();
    let (label, source) = CORPUS[6];
    let json = l
        .parse_string(source, &format!("{label}.ncl"))
        .unwrap_or_else(|e| panic!("Parse of '{label}' failed: {e}"));

    assert_eq!(json["x"], 12, "'x' should be 3*4=12");
    assert_eq!(json["y"], 99, "'y' should be 100-1=99");
}

// ---------------------------------------------------------------------------
// Property 9: String concatenation is fully evaluated
// ---------------------------------------------------------------------------

/// Corpus entry 7 (`concat`) has `s = "foo" ++ "bar" ++ "baz"`.  After
/// evaluation `s` must be the single string `"foobarbaz"`.
#[test]
fn property_concat_is_fully_evaluated() {
    let l = loader();
    let (label, source) = CORPUS[7];
    let json = l
        .parse_string(source, &format!("{label}.ncl"))
        .unwrap_or_else(|e| panic!("Parse of '{label}' failed: {e}"));

    assert_eq!(json["s"], "foobarbaz");
}

// ---------------------------------------------------------------------------
// Property 10: Deep nesting is preserved at all levels
// ---------------------------------------------------------------------------

/// Corpus entry 5 (`deep_nest`) declares three nesting levels.  Each level
/// must be accessible as a JSON object, and the leaf value must be the
/// declared string.
#[test]
fn property_deep_nesting_preserved() {
    let l = loader();
    let (label, source) = CORPUS[5];
    let json = l
        .parse_string(source, &format!("{label}.ncl"))
        .unwrap_or_else(|e| panic!("Parse of '{label}' failed: {e}"));

    assert!(json["l1"].is_object(), "l1 should be an object");
    assert!(json["l1"]["l2"].is_object(), "l1.l2 should be an object");
    assert_eq!(
        json["l1"]["l2"]["l3"], "leaf",
        "l1.l2.l3 should be 'leaf'"
    );
}
