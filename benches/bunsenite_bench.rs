// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//! Throughput benchmarks for Bunsenite — small, medium, and large payloads.
//!
//! Complements `parser.rs` (which benchmarks round-trip parse/validate) with
//! focused throughput measurements across payload sizes, including loader
//! creation overhead and the `validate`-only fast path.

use bunsenite::NickelLoader;
use criterion::{black_box, criterion_group, criterion_main, BenchmarkId, Criterion, Throughput};

// ---------------------------------------------------------------------------
// Payload corpus
// ---------------------------------------------------------------------------

/// Small payload (~80 bytes) — a minimal three-field record.
const SMALL_PAYLOAD: &str = r#"{ name = "small", port = 8080, active = true }"#;

/// Medium payload (~350 bytes) — a two-section server/database record.
const MEDIUM_PAYLOAD: &str = r#"
{
  application = {
    name = "medium-service",
    version = "2.1.0",
    environment = "staging",
  },
  database = {
    host = "db.staging.example.com",
    port = 5432,
    name = "staging_db",
    pool_min = 2,
    pool_max = 10,
    ssl = true,
  },
  server = {
    bind = "0.0.0.0",
    port = 8443,
    workers = 8,
    timeout_ms = 5000,
  },
}
"#;

/// Large payload (~900 bytes) — a multi-section config with arrays and nesting.
const LARGE_PAYLOAD: &str = r#"
{
  service = {
    name = "large-service",
    version = "3.0.0",
    region = "eu-west-1",
    replicas = 5,
  },
  endpoints = [
    { path = "/health",  method = "GET",  auth = false },
    { path = "/api/v1",  method = "GET",  auth = true  },
    { path = "/api/v1",  method = "POST", auth = true  },
    { path = "/metrics", method = "GET",  auth = false },
  ],
  database = {
    primary   = { host = "db-primary.internal",  port = 5432, pool = 20 },
    secondary = { host = "db-secondary.internal", port = 5432, pool = 10 },
    migrations = { auto = false, path = "migrations/" },
  },
  cache = {
    provider = "redis",
    host = "cache.internal",
    port = 6379,
    ttl_seconds = 300,
    max_entries = 50000,
  },
  logging = {
    level = "warn",
    structured = true,
    sinks = ["stdout", "loki"],
  },
  features = {
    dark_mode = false,
    beta_api  = true,
    rate_limit = { enabled = true, rps = 500 },
  },
}
"#;

// ---------------------------------------------------------------------------
// Benchmark 1: Throughput by payload size (parse_string)
// ---------------------------------------------------------------------------

/// Measure `parse_string` throughput — bytes-per-second — for the three
/// payload sizes.  This is the primary end-to-end measurement.
fn bench_throughput_parse(c: &mut Criterion) {
    let loader = NickelLoader::new();
    let mut group = c.benchmark_group("throughput/parse_string");

    for (label, payload) in [
        ("small", SMALL_PAYLOAD),
        ("medium", MEDIUM_PAYLOAD),
        ("large", LARGE_PAYLOAD),
    ] {
        group.throughput(Throughput::Bytes(payload.len() as u64));
        group.bench_with_input(
            BenchmarkId::new(label, payload.len()),
            payload,
            |b, src| b.iter(|| loader.parse_string(black_box(src), "bench.ncl")),
        );
    }

    group.finish();
}

// ---------------------------------------------------------------------------
// Benchmark 2: Throughput by payload size (validate — parsing only, no eval)
// ---------------------------------------------------------------------------

/// Measure `validate` throughput for the same three payloads.  `validate`
/// skips evaluation, so it is expected to be faster than `parse_string` and
/// serves as a lower bound on parser overhead.
fn bench_throughput_validate(c: &mut Criterion) {
    let loader = NickelLoader::new();
    let mut group = c.benchmark_group("throughput/validate");

    for (label, payload) in [
        ("small", SMALL_PAYLOAD),
        ("medium", MEDIUM_PAYLOAD),
        ("large", LARGE_PAYLOAD),
    ] {
        group.throughput(Throughput::Bytes(payload.len() as u64));
        group.bench_with_input(
            BenchmarkId::new(label, payload.len()),
            payload,
            |b, src| b.iter(|| loader.validate(black_box(src), "bench.ncl")),
        );
    }

    group.finish();
}

// ---------------------------------------------------------------------------
// Benchmark 3: Loader construction overhead
// ---------------------------------------------------------------------------

/// Measure the cost of calling `NickelLoader::new()`.  This baseline confirms
/// that the loader itself is cheap to create and that callers may safely
/// construct one per-request if needed.
fn bench_loader_creation(c: &mut Criterion) {
    c.bench_function("loader_creation", |b| {
        b.iter(|| black_box(NickelLoader::new()))
    });
}

// ---------------------------------------------------------------------------
// Benchmark 4: Repeated small-payload parses on a shared loader
// ---------------------------------------------------------------------------

/// Measures repeated small-config parses on a single long-lived loader to
/// detect any state accumulation or degradation in the loader between calls.
fn bench_repeated_small_on_shared_loader(c: &mut Criterion) {
    let loader = NickelLoader::new();
    c.bench_function("repeated_small/shared_loader", |b| {
        b.iter(|| loader.parse_string(black_box(SMALL_PAYLOAD), "rep.ncl"))
    });
}

// ---------------------------------------------------------------------------
// Benchmark 5: Error path — parse of invalid input
// ---------------------------------------------------------------------------

/// Measures the cost of the error path: how quickly the parser rejects
/// obviously invalid Nickel.  A fast error path matters for tooling that
/// validates user input interactively.
fn bench_error_path(c: &mut Criterion) {
    let loader = NickelLoader::new();
    let invalid = "{ broken syntax @@@ !!!";
    c.bench_function("error_path/invalid_input", |b| {
        b.iter(|| loader.parse_string(black_box(invalid), "invalid.ncl"))
    });
}

// ---------------------------------------------------------------------------
// Criterion wiring
// ---------------------------------------------------------------------------

criterion_group!(
    benches,
    bench_throughput_parse,
    bench_throughput_validate,
    bench_loader_creation,
    bench_repeated_small_on_shared_loader,
    bench_error_path,
);
criterion_main!(benches);
