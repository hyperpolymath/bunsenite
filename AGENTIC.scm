; SPDX-License-Identifier: PMPL-1.0-or-later
; AGENTIC.scm - AI agent instructions for bunsenite
; Media type: application/vnd.agentic+scm

(agentic
  (metadata
    (version "1.0.0")
    (schema-version "1.0")
    (created "2026-01-30")
    (updated "2026-01-30"))

  (agent-identity
    (project "bunsenite")
    (role "development-assistant")
    (capabilities
      "Nickel language expertise"
      "Rust development and optimization"
      "WASM compilation and testing"
      "FFI bindings (C, Zig, ReScript, Deno)"
      "Configuration DSL design"))

  (language-policy
    (allowed
      (language "Rust" (use-case "core parser, CLI, WASM target"))
      (language "Nickel" (use-case "embedded DSL, configuration"))
      (language "ReScript" (use-case "JS/WASM bindings"))
      (language "Zig" (use-case "C FFI layer"))
      (language "Guile Scheme" (use-case "SCM files"))
      (language "Bash" (use-case "minimal scripts only")))
    (banned
      (language "TypeScript" (replacement "ReScript"))
      (language "Python" (replacement "Rust"))
      (language "Go" (replacement "Rust"))
      (language "Node.js" (replacement "Deno"))))

  (code-standards
    (rust
      (edition "2021")
      (msrv "1.70")
      (lints "clippy::pedantic")
      (format "rustfmt default")
      (features "cli" "wasm" "watch" "repl"))
    (nickel
      (style "Nickel configuration best practices")
      (validation "Type-checked contracts"))
    (rescript
      (output "es6")
      (suffix ".mjs")
      (stdlib "@rescript/core"))
    (general
      (line-endings "LF")
      (indent "spaces")
      (max-line-length 100)
      (spdx-headers required)))

  (task-guidelines
    (before-coding
      "Read STATE.scm for current parser state"
      "Check META.scm for Nickel language design decisions"
      "Review existing parser implementation")
    (during-coding
      "Follow Rust idioms strictly"
      "Maintain zero unsafe code (cargo-geiger clean)"
      "Add fuzzing targets for new parsers"
      "Write comprehensive tests")
    (after-coding
      "Run cargo test --all-features"
      "Run cargo bench for performance"
      "Run cargo fuzz for at least 5 minutes"
      "Update STATE.scm if milestones achieved"))

  (prohibited-actions
    "Never introduce banned languages"
    "Never add unsafe code without justification"
    "Never skip fuzzing for parser changes"
    "Never remove SPDX headers"
    "Never break WASM compatibility")

  (autonomous-permissions
    (allowed
      "Fix Rust compiler warnings"
      "Optimize parser performance"
      "Add parser tests"
      "Update Nickel language support"
      "Format code with rustfmt")
    (requires-approval
      "Change Nickel syntax parsing"
      "Add new Cargo features"
      "Modify C FFI interface"
      "Change WASM export signature")))
