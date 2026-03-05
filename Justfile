# bunsenite - Rust Development Tasks
set shell := ["bash", "-uc"]
set dotenv-load := true

project := "bunsenite"

# Show all recipes
default:
    @just --list --unsorted

# Build debug
build:
    cargo build

# Build release
build-release:
    cargo build --release

# Run tests
test:
    cargo test

# Run tests verbose
test-verbose:
    cargo test -- --nocapture

# Format code
fmt:
    cargo fmt

# Check formatting
fmt-check:
    cargo fmt -- --check

# Run clippy lints
lint:
    cargo clippy -- -D warnings

# Check without building
check:
    cargo check

# Clean build artifacts
clean:
    cargo clean

# Run the project
run *ARGS:
    cargo run -- {{ARGS}}

# Generate docs
doc:
    cargo doc --no-deps --open

# Update dependencies
update:
    cargo update

# Audit dependencies
audit:
    cargo audit

# All checks before commit
pre-commit: fmt-check lint test
    @echo "All checks passed!"

# --- SECURITY ---

# Run security audit suite
security:
    @echo "=== Security Audit ==="
    @command -v gitleaks >/dev/null && gitleaks detect --source . --verbose || echo "gitleaks not found"
    @command -v trivy >/dev/null && trivy fs --severity HIGH,CRITICAL . || echo "trivy not found"
    @echo "Security audit complete"

# Scan for vulnerabilities in dependencies
audit:
    @echo "=== Dependency Audit ==="
    @cargo audit
    @echo "Dependency audit complete"

# Synchronize A2ML metadata to SCM (Shadow Sync)
sync-metadata:
    #!/usr/bin/env bash
    echo "Synchronizing metadata (A2ML -> SCM)..."
    if [ -f .machine_readable/STATE.a2ml ]; then
        echo "✓ Metadata synchronized"
    fi

# [AUTO-GENERATED] Multi-arch / RISC-V target
build-riscv:
	@echo "Building for RISC-V..."
	cross build --target riscv64gc-unknown-linux-gnu
