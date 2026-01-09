//! Performance benchmarks for Bunsenite
//!
//! Run with: cargo bench

use bunsenite::NickelLoader;
use criterion::{black_box, criterion_group, criterion_main, BenchmarkId, Criterion, Throughput};

/// Simple configuration (~100 bytes)
const SIMPLE_CONFIG: &str = r#"
{
  name = "simple",
  version = "1.0.0",
  enabled = true,
}
"#;

/// Medium configuration (~500 bytes)
const MEDIUM_CONFIG: &str = r#"
{
  name = "medium",
  version = "1.0.0",
  database = {
    host = "localhost",
    port = 5432,
    name = "mydb",
    ssl = true,
  },
  server = {
    host = "0.0.0.0",
    port = 8080,
    workers = 4,
    timeout = 30,
  },
  logging = {
    level = "info",
    format = "json",
    file = "/var/log/app.log",
  },
  features = {
    auth = true,
    cache = true,
    metrics = true,
  },
}
"#;

/// Complex configuration with contracts (~1500 bytes)
const COMPLEX_CONFIG: &str = r#"
let Port = std.contract.from_predicate (fun x => x >= 1 && x <= 65535) in
let NonEmpty = std.contract.from_predicate (fun x => std.string.length x > 0) in

{
  name | NonEmpty = "complex-app",
  version = "2.0.0",

  database = {
    primary = {
      host | NonEmpty = "db-primary.example.com",
      port | Port = 5432,
      name = "production",
      pool_size = 20,
      ssl = {
        enabled = true,
        verify = true,
        ca_cert = "/etc/ssl/certs/ca.pem",
      },
    },
    replica = {
      host | NonEmpty = "db-replica.example.com",
      port | Port = 5432,
      name = "production",
      pool_size = 10,
    },
  },

  servers = [
    { name = "web-1", host = "10.0.1.1", port | Port = 8080 },
    { name = "web-2", host = "10.0.1.2", port | Port = 8080 },
    { name = "web-3", host = "10.0.1.3", port | Port = 8080 },
  ],

  cache = {
    redis = {
      host = "redis.example.com",
      port | Port = 6379,
      db = 0,
      ttl = 3600,
    },
  },

  logging = {
    level = "info",
    outputs = [
      { type = "console", format = "pretty" },
      { type = "file", path = "/var/log/app.log", format = "json" },
      { type = "syslog", facility = "local0" },
    ],
  },

  features = {
    authentication = { enabled = true, provider = "oauth2" },
    rate_limiting = { enabled = true, requests_per_minute = 100 },
    caching = { enabled = true, strategy = "lru" },
    metrics = { enabled = true, endpoint = "/metrics" },
  },
}
"#;

fn benchmark_parse(c: &mut Criterion) {
    let loader = NickelLoader::new();

    let mut group = c.benchmark_group("parse");

    // Simple config
    group.throughput(Throughput::Bytes(SIMPLE_CONFIG.len() as u64));
    group.bench_with_input(
        BenchmarkId::new("simple", SIMPLE_CONFIG.len()),
        &SIMPLE_CONFIG,
        |b, config| b.iter(|| loader.parse(black_box(*config), "simple.ncl")),
    );

    // Medium config
    group.throughput(Throughput::Bytes(MEDIUM_CONFIG.len() as u64));
    group.bench_with_input(
        BenchmarkId::new("medium", MEDIUM_CONFIG.len()),
        &MEDIUM_CONFIG,
        |b, config| b.iter(|| loader.parse(black_box(*config), "medium.ncl")),
    );

    // Complex config
    group.throughput(Throughput::Bytes(COMPLEX_CONFIG.len() as u64));
    group.bench_with_input(
        BenchmarkId::new("complex", COMPLEX_CONFIG.len()),
        &COMPLEX_CONFIG,
        |b, config| b.iter(|| loader.parse(black_box(*config), "complex.ncl")),
    );

    group.finish();
}

fn benchmark_validate(c: &mut Criterion) {
    let loader = NickelLoader::new();

    let mut group = c.benchmark_group("validate");

    group.bench_with_input(
        BenchmarkId::new("simple", SIMPLE_CONFIG.len()),
        &SIMPLE_CONFIG,
        |b, config| b.iter(|| loader.validate(black_box(*config), "simple.ncl")),
    );

    group.bench_with_input(
        BenchmarkId::new("medium", MEDIUM_CONFIG.len()),
        &MEDIUM_CONFIG,
        |b, config| b.iter(|| loader.validate(black_box(*config), "medium.ncl")),
    );

    group.bench_with_input(
        BenchmarkId::new("complex", COMPLEX_CONFIG.len()),
        &COMPLEX_CONFIG,
        |b, config| b.iter(|| loader.validate(black_box(*config), "complex.ncl")),
    );

    group.finish();
}

fn benchmark_loader_creation(c: &mut Criterion) {
    c.bench_function("loader_creation", |b| {
        b.iter(|| black_box(NickelLoader::new()))
    });
}

criterion_group!(
    benches,
    benchmark_parse,
    benchmark_validate,
    benchmark_loader_creation
);
criterion_main!(benches);
