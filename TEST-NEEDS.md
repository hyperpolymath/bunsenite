# Test & Benchmark Requirements

## Current State
- Unit tests: NONE verified (Cargo.toml exists but cargo not available in this repo due to .tool-versions mismatch)
- Integration tests: 1 Zig integration test (template)
- E2E tests: NONE
- Benchmarks: 1 file exists (unverified)
- panic-attack scan: NEVER RUN

## What's Missing
### Point-to-Point (P2P)
- 11 Rust source files — test count unknown (cannot build)
- 5 Zig source files — only template integration test
- 3 Idris2 ABI files — no verification tests
- 4 ReScript files — no tests
- 3 TypeScript files — no tests

### End-to-End (E2E)
- Core functionality workflow not tested
- Integration between Rust, Zig, and ReScript layers not tested

### Aspect Tests
- [ ] Security (depends on what bunsenite does)
- [ ] Performance (benchmark file exists but unverified)
- [ ] Concurrency (if applicable)
- [ ] Error handling (graceful degradation)
- [ ] Accessibility (if UI exists)

### Build & Execution
- [ ] cargo build — BLOCKED (.tool-versions mismatch)
- [ ] cargo test — BLOCKED
- [ ] zig build — not verified
- [ ] Self-diagnostic — none

### Benchmarks Needed
- Verify existing benchmark file runs
- Specific benchmarks depend on functionality

### Self-Tests
- [ ] panic-attack assail on own repo
- [ ] Fix .tool-versions to allow cargo to run

## Priority
- **MEDIUM** — 11 Rust + 5 Zig + 4 ReScript + 3 TS files. Cannot even build due to tooling mismatch, which itself is a problem. Fix .tool-versions first, then assess test needs.
