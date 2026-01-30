K9!
# SPDX-License-Identifier: PMPL-1.0-or-later
# Bunsenite Development Environment Setup
#
# This K9 component automates the setup of a complete Bunsenite development
# environment, including Rust toolchain, dependencies, pre-commit hooks, and
# test infrastructure.

leash = 'Hunt

pedigree = {
  schema_version = "1.0.0",
  component_type = "dev-env-setup",
  author = "Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>",
  description = "Automated development environment setup for Bunsenite",
  created = "2026-01-30",
  k9_spec_version = "1.0.0",
}

# Configuration with Nickel contracts
config = {
  rust_version | String = "stable",
  install_nightly | Bool = true,  # For WASM builds
  setup_git_hooks | Bool = true,
  install_cargo_tools | Bool = true,
  run_initial_tests | Bool = true,

  # Required Cargo tools for Bunsenite development
  cargo_tools | Array String = [
    "cargo-audit",      # Security auditing
    "cargo-outdated",   # Dependency updates
    "cargo-deny",       # License/dependency policy
    "cargo-watch",      # Auto-rebuild on changes
    "cargo-expand",     # Macro expansion debugging
    "wasm-pack",        # WASM builds
  ],

  # Target platforms to install
  targets | Array String = [
    "wasm32-unknown-unknown",  # Browser WASM
    "wasm32-wasi",             # WASI WASM
  ],

  # Pre-commit hooks to install
  git_hooks | { _ : String } = {
    "pre-commit" = "#!/bin/bash\nset -e\ncargo fmt --check\ncargo clippy -- -D warnings\n",
    "pre-push" = "#!/bin/bash\nset -e\ncargo test\ncargo audit\n",
  },
}

# Just recipes for setup tasks
recipes = {
  default = {
    recipe = "setup-all",
    description = "Complete development environment setup",
  },

  "check-rust" = {
    description = "Verify Rust toolchain is installed",
    commands = [
      "command -v rustc >/dev/null 2>&1 || { echo 'Error: Rust not found. Install from https://rustup.rs/'; exit 1; }",
      "rustc --version",
      "cargo --version",
    ],
  },

  "install-toolchain" = {
    description = "Install Rust toolchains and targets",
    dependencies = ["check-rust"],
    commands = [
      "rustup install %{config.rust_version}",
      "rustup default %{config.rust_version}",
    ] @ (
      if config.install_nightly then
        ["rustup install nightly", "rustup component add rust-src --toolchain nightly"]
      else
        []
    ) @ (
      config.targets
      |> std.array.map (fun target => "rustup target add %{target}")
    ),
  },

  "install-cargo-tools" = {
    description = "Install Cargo development tools",
    dependencies = ["install-toolchain"],
    skip = !config.install_cargo_tools,
    commands = config.cargo_tools
      |> std.array.map (fun tool => "cargo install %{tool} || echo 'Warning: %{tool} install failed'"),
  },

  "setup-git-hooks" = {
    description = "Install Git pre-commit and pre-push hooks",
    skip = !config.setup_git_hooks,
    commands =
      config.git_hooks
      |> std.record.to_array
      |> std.array.map (fun entry =>
        let name = std.string.from entry.field in
        let content = entry.value in
        [
          "mkdir -p .git/hooks",
          "cat > .git/hooks/%{name} <<'HOOK_EOF'\n%{content}\nHOOK_EOF",
          "chmod +x .git/hooks/%{name}",
          "echo 'Installed %{name} hook'",
        ]
      )
      |> std.array.flatten,
  },

  "build-debug" = {
    description = "Build Bunsenite in debug mode",
    dependencies = ["install-toolchain"],
    commands = [
      "cargo build",
      "echo 'Debug build complete: target/debug/bunsenite'",
    ],
  },

  "build-release" = {
    description = "Build Bunsenite in release mode with optimizations",
    dependencies = ["install-toolchain"],
    commands = [
      "cargo build --release",
      "ls -lh target/release/bunsenite",
      "echo 'Release build complete'",
    ],
  },

  "build-wasm" = {
    description = "Build WASM bindings for browser",
    dependencies = ["install-cargo-tools"],
    commands = [
      "cd wasm && wasm-pack build --target web",
      "echo 'WASM build complete: wasm/pkg/'",
    ],
  },

  "run-tests" = {
    description = "Run full test suite",
    skip = !config.run_initial_tests,
    commands = [
      "cargo test --all-features",
      "cargo test --release --all-features",
    ],
  },

  "security-audit" = {
    description = "Run security and license audits",
    dependencies = ["install-cargo-tools"],
    commands = [
      "cargo audit",
      "cargo deny check",
    ],
  },

  "setup-all" = {
    description = "Complete development environment setup (default)",
    dependencies = [
      "check-rust",
      "install-toolchain",
      "install-cargo-tools",
      "setup-git-hooks",
      "build-debug",
      "run-tests",
    ],
    commands = [
      "echo ''",
      "echo '╔══════════════════════════════════════════════════════════╗'",
      "echo '║  ✅ Bunsenite Development Environment Setup Complete!  ║'",
      "echo '╚══════════════════════════════════════════════════════════╝'",
      "echo ''",
      "echo 'Next steps:'",
      "echo '  1. Build WASM bindings:  just build-wasm'",
      "echo '  2. Run security audit:   just security-audit'",
      "echo '  3. Start development:    cargo watch -x check -x test'",
      "echo ''",
    ],
  },
}

# Validation contracts
validation = {
  # Ensure Rust version is valid
  rust_version_valid =
    config.rust_version == "stable"
    || config.rust_version == "nightly"
    || config.rust_version == "beta"
    | doc "Rust version must be stable, nightly, or beta",

  # Ensure at least one cargo tool is selected
  has_cargo_tools =
    !config.install_cargo_tools
    || std.array.length config.cargo_tools > 0
    | doc "If install_cargo_tools is true, must specify at least one tool",

  # Ensure WASM target is installed if building WASM
  wasm_target_included =
    std.array.any (fun t => t == "wasm32-unknown-unknown") config.targets
    | doc "wasm32-unknown-unknown target required for WASM builds",
}
