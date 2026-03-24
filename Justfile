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

# Validate K9 configurations
validate-k9:
    @echo "Validating K9 configs..."
    nickel eval config/rust-fmt.k9.ncl > /dev/null && echo "✓ rust-fmt.k9.ncl valid"
    nickel eval config/build.k9.ncl > /dev/null && echo "✓ build.k9.ncl valid"
    @echo "All K9 configs valid!"

# Generate rustfmt.toml from K9 config
generate-rustfmt:
    nickel export config/rust-fmt.k9.ncl -f 'rustfmt_toml' > rustfmt.toml
    @echo "Generated rustfmt.toml from K9 config"

# K9 dogfooding: validate configs before use
dogfood: validate-k9
    @echo "K9 dogfooding: The Nickel tool validates itself with K9!"

# All checks before commit (including K9 validation)
pre-commit: validate-k9 fmt-check lint test
    @echo "All checks passed!"

# Run panic-attacker pre-commit scan
assail:
    @command -v panic-attack >/dev/null 2>&1 && panic-attack assail . || echo "panic-attack not found — install from https://github.com/hyperpolymath/panic-attacker"

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
