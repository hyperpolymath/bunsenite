; SPDX-License-Identifier: PMPL-1.0-or-later
; PLAYBOOK.scm - Operational playbook for bunsenite
; Media type: application/vnd.playbook+scm

(playbook
  (metadata
    (version "1.0.0")
    (schema-version "1.0")
    (created "2026-01-30")
    (updated "2026-01-30"))

  (quick-start
    (prerequisites
      "Rust 1.70+"
      "cargo and rustc"
      "Just task runner (optional)")
    (steps
      (step 1 "Clone repository" "git clone https://github.com/hyperpolymath/bunsenite")
      (step 2 "Build" "cargo build --release")
      (step 3 "Run tests" "cargo test")
      (step 4 "Install CLI" "cargo install --path .")))

  (common-tasks
    (development
      (task "Build debug"
        (command "cargo build")
        (when "Local development"))
      (task "Build release with all features"
        (command "cargo build --release --all-features")
        (when "Creating release binaries"))
      (task "Run all tests"
        (command "cargo test --all-features")
        (when "Before committing"))
      (task "Run fuzzing"
        (command "cargo +nightly fuzz run fuzz_nickel_parser -- -max_total_time=300")
        (when "Security testing"))
      (task "Benchmark"
        (command "cargo bench")
        (when "Performance validation"))
      (task "Check with clippy"
        (command "cargo clippy --all-features -- -D warnings")
        (when "Code quality checks")))

    (operations
      (task "Parse Nickel file"
        (command "bunsenite parse config.ncl")
        (when "Validating configuration"))
      (task "Start REPL"
        (command "bunsenite repl")
        (when "Interactive Nickel exploration"))
      (task "Watch mode"
        (command "bunsenite watch --file config.ncl")
        (when "Development with hot reload"))
      (task "Build WASM"
        (command "cargo build --target wasm32-unknown-unknown --features wasm")
        (when "Browser deployment"))))

  (troubleshooting
    (issue "Parse errors in Nickel files"
      (symptoms "Error: unexpected token" "Parse failed")
      (diagnosis "Check Nickel syntax" "Verify file encoding is UTF-8")
      (resolution "Use bunsenite --verbose for detailed errors" "Check against Nickel spec"))

    (issue "WASM build fails"
      (symptoms "Error: wasm32-unknown-unknown not found")
      (diagnosis "Missing WASM target")
      (resolution "rustup target add wasm32-unknown-unknown"))

    (issue "Feature compilation errors"
      (symptoms "Error: feature X not found")
      (diagnosis "Optional feature not enabled")
      (resolution "Build with --features cli,wasm,watch,repl as needed")))

  (maintenance
    (daily)
    (weekly
      (task "Run full test suite" "cargo test --all-features")
      (task "Run fuzzing session" "cargo fuzz run fuzz_nickel_parser"))
    (monthly
      (task "Update dependencies" "cargo update")
      (task "Security audit" "cargo audit")
      (task "Benchmark performance" "cargo bench"))
    (quarterly
      (task "Review and update documentation")
      (task "Update Nickel language support"))))
