;;; STATE.scm — Bunsenite Project State Checkpoint
;;; Format: https://github.com/hyperpolymath/state.scm
;;;
;;; Download this file at end of each session!
;;; At start of next conversation, upload it.

(define state
  '((metadata
     (version . "0.1.0")
     (created . "2025-12-08")
     (updated . "2025-12-08")
     (generator . "claude-opus-4"))

    (user
     (name . "hyperpolymath")
     (roles . (maintainer architect))
     (languages . (rust zig typescript rescript scheme))
     (tools . (cargo just wasm-pack deno nix guix))
     (values . (type-safety memory-safety offline-first emotional-safety)))

    (session
     (conversation-id . "claude/create-state-scm-0186oHqPyBk4atsYcVa1qtda")
     (messages . 1)
     (token-limit . 200000)
     (tokens-remaining . "~195000"))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; CURRENT POSITION
    ;; ═══════════════════════════════════════════════════════════════════

    (focus
     (project . "bunsenite")
     (phase . "post-release")
     (milestone . "v0.1.0 published, pursuing v1.0 MVP")
     (blocking . (publishing-incomplete zig-ffi-not-implemented)))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; PROJECT CATALOG
    ;; ═══════════════════════════════════════════════════════════════════
    ;;
    ;; Status values: in-progress | blocked | paused | complete | abandoned
    ;; Categories: core | ffi | bindings | tooling | docs | infra | community

    (projects
     ;; ─────────────────────────────────────────────────────────────────
     ;; CORE LIBRARY (COMPLETE)
     ;; ─────────────────────────────────────────────────────────────────
     ((id . "rust-core")
      (name . "Rust Core Library")
      (status . complete)
      (completion . 100)
      (category . core)
      (phase . "released")
      (depends . ())
      (notes . "nickel-lang-core 0.9.1 integration complete, 8 tests passing")
      (next-action . "maintenance only"))

     ((id . "wasm-bindings")
      (name . "WebAssembly Bindings")
      (status . complete)
      (completion . 100)
      (category . bindings)
      (phase . "released")
      (depends . (rust-core))
      (notes . "wasm-bindgen integration, ~95% native speed")
      (next-action . "publish to npm (optional)"))

     ((id . "cli")
      (name . "Command Line Interface")
      (status . complete)
      (completion . 100)
      (category . tooling)
      (phase . "released")
      (depends . (rust-core))
      (notes . "parse, validate, info commands working")
      (next-action . "none"))

     ;; ─────────────────────────────────────────────────────────────────
     ;; FFI LAYER (BLOCKED)
     ;; ─────────────────────────────────────────────────────────────────
     ((id . "zig-ffi")
      (name . "Zig C ABI Layer")
      (status . blocked)
      (completion . 10)
      (category . ffi)
      (phase . "design")
      (depends . (rust-core))
      (blocker . "Zig FFI wrapper not yet implemented")
      (notes . "Critical for stable C ABI across Rust versions")
      (next-action . "implement zig/bunsenite.zig with C ABI exports"))

     ((id . "deno-bindings")
      (name . "Deno TypeScript Bindings")
      (status . blocked)
      (completion . 30)
      (category . bindings)
      (phase . "scaffolded")
      (depends . (zig-ffi))
      (blocker . "Waiting on Zig FFI layer")
      (notes . "Uses Deno.dlopen, NOT plain TypeScript")
      (next-action . "complete after zig-ffi"))

     ((id . "rescript-bindings")
      (name . "Rescript C FFI Bindings")
      (status . blocked)
      (completion . 20)
      (category . bindings)
      (phase . "scaffolded")
      (depends . (zig-ffi))
      (blocker . "Waiting on Zig FFI layer")
      (next-action . "complete after zig-ffi"))

     ;; ─────────────────────────────────────────────────────────────────
     ;; PUBLISHING (IN PROGRESS)
     ;; ─────────────────────────────────────────────────────────────────
     ((id . "crates-io")
      (name . "Publish to crates.io")
      (status . in-progress)
      (completion . 50)
      (category . infra)
      (phase . "ready")
      (depends . (rust-core))
      (notes . "cargo publish --dry-run should work")
      (next-action . "run cargo publish"))

     ((id . "gitlab-release")
      (name . "Create GitLab Release")
      (status . in-progress)
      (completion . 30)
      (category . infra)
      (phase . "tagged")
      (depends . (rust-core))
      (notes . "Tag v0.1.0 exists, release page not created")
      (next-action . "create release with binaries at GitLab"))

     ((id . "aur-package")
      (name . "Arch User Repository Package")
      (status . paused)
      (completion . 0)
      (category . infra)
      (phase . "not-started")
      (depends . (crates-io))
      (notes . "Optional, low priority")
      (next-action . "create PKGBUILD after crates.io"))

     ;; ─────────────────────────────────────────────────────────────────
     ;; MVP V1.0 FEATURES (PLANNED)
     ;; ─────────────────────────────────────────────────────────────────
     ((id . "error-messages")
      (name . "Improved Error Messages")
      (status . paused)
      (completion . 0)
      (category . core)
      (phase . "planned")
      (depends . (rust-core))
      (notes . "Add line/column numbers, pretty-print with miette")
      (next-action . "design error message format"))

     ((id . "schema-validation")
      (name . "Configuration Schema Validation")
      (status . paused)
      (completion . 0)
      (category . core)
      (phase . "planned")
      (depends . (rust-core))
      (notes . "Define schema, validate configs against it")
      (next-action . "design schema DSL"))

     ((id . "watch-mode")
      (name . "Watch Mode / Auto-Reload")
      (status . paused)
      (completion . 0)
      (category . tooling)
      (phase . "planned")
      (depends . (cli))
      (notes . "bunsenite watch config.ncl --on-change CMD")
      (next-action . "add notify crate dependency"))

     ((id . "repl")
      (name . "Interactive REPL")
      (status . paused)
      (completion . 0)
      (category . tooling)
      (phase . "planned")
      (depends . (rust-core))
      (notes . "Interactive Nickel evaluation with history")
      (next-action . "add rustyline dependency"))

     ;; ─────────────────────────────────────────────────────────────────
     ;; ADDITIONAL BINDINGS (LONG TERM)
     ;; ─────────────────────────────────────────────────────────────────
     ((id . "python-bindings")
      (name . "Python Bindings (PyO3)")
      (status . paused)
      (completion . 0)
      (category . bindings)
      (phase . "planned")
      (depends . (rust-core))
      (next-action . "add pyo3 to Cargo.toml"))

     ((id . "nodejs-bindings")
      (name . "Node.js Bindings (NAPI-RS)")
      (status . paused)
      (completion . 0)
      (category . bindings)
      (phase . "planned")
      (depends . (rust-core))
      (next-action . "add napi-rs to Cargo.toml"))

     ((id . "lsp")
      (name . "Language Server Protocol")
      (status . paused)
      (completion . 0)
      (category . tooling)
      (phase . "research")
      (depends . (rust-core error-messages))
      (notes . "IDE integration, diagnostics, completion")
      (next-action . "research tower-lsp crate")))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; ROUTE TO MVP V1.0
    ;; ═══════════════════════════════════════════════════════════════════
    ;;
    ;; Phase 1: Complete Publishing (current)
    ;;   1. Create GitLab release with binaries
    ;;   2. Publish to crates.io
    ;;   3. Announce on /r/rust
    ;;
    ;; Phase 2: Complete FFI Layer
    ;;   4. Implement Zig C ABI wrapper
    ;;   5. Complete Deno bindings
    ;;   6. Complete Rescript bindings
    ;;   7. Test FFI stability across Rust versions
    ;;
    ;; Phase 3: Core Improvements
    ;;   8. Improve error messages (miette integration)
    ;;   9. Add schema validation
    ;;  10. Implement watch mode
    ;;  11. Build interactive REPL
    ;;
    ;; Phase 4: Polish & Release v1.0
    ;;  12. Performance benchmarking
    ;;  13. Expand test suite to 90%+ coverage
    ;;  14. Documentation polish
    ;;  15. Security audit
    ;;  16. Tag and release v1.0.0

    ;; ═══════════════════════════════════════════════════════════════════
    ;; ISSUES / BLOCKERS
    ;; ═══════════════════════════════════════════════════════════════════

    (issues
     ((id . "issue-001")
      (severity . high)
      (title . "Zig FFI layer not implemented")
      (description . "The Zig C ABI wrapper is documented but not built. Deno and Rescript bindings depend on this.")
      (impact . "Blocks 2 of 5 planned binding targets")
      (proposed-solution . "Implement zig/bunsenite.zig exporting parse_nickel_ffi, free_string_ffi"))

     ((id . "issue-002")
      (severity . medium)
      (title . "GitLab HTTP push may be disabled")
      (description . "CLAUDE.md notes that HTTP push may not work; SSH or API required")
      (impact . "Complicates CI/CD and contributor workflow")
      (proposed-solution . "Configure SSH deploy keys or use GitLab API for releases"))

     ((id . "issue-003")
      (severity . low)
      (title . "nickel-lang-core version lock")
      (description . "Locked to 0.9.1 due to API changes; newer versions may break compatibility")
      (impact . "May miss upstream improvements and security fixes")
      (proposed-solution . "Monitor nickel-lang-core releases, test compatibility before upgrade"))

     ((id . "issue-004")
      (severity . low)
      (title . "WASM not published to npm")
      (description . "WASM module built but not published to npm registry")
      (impact . "Reduces discoverability for JS ecosystem")
      (proposed-solution . "Set up npm account, run wasm-pack publish")))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; QUESTIONS FOR MAINTAINER
    ;; ═══════════════════════════════════════════════════════════════════

    (questions
     ((id . "q-001")
      (priority . high)
      (question . "Should Zig FFI be prioritized over additional language bindings?")
      (context . "Zig FFI blocks Deno/Rescript but Python/Node can use WASM or direct Rust")
      (options . ("Prioritize Zig FFI first" "Add Python bindings via PyO3 first" "Both in parallel")))

     ((id . "q-002")
      (priority . medium)
      (question . "What is the target timeline for v1.0.0 release?")
      (context . "Affects prioritization and scope decisions")
      (options . ("Q1 2025" "Q2 2025" "When ready, no deadline")))

     ((id . "q-003")
      (priority . medium)
      (question . "Should WASM be published to npm under @bunsenite scope?")
      (context . "Increases JS ecosystem visibility but requires npm account setup")
      (options . ("Yes, publish to npm" "No, WASM from GitLab releases is sufficient")))

     ((id . "q-004")
      (priority . low)
      (question . "Is AUR packaging still desired?")
      (context . "Mentioned in PUBLISHING.md but marked optional")
      (options . ("Yes, publish to AUR" "No, skip AUR" "Defer to community contributor")))

     ((id . "q-005")
      (priority . low)
      (question . "Should CI/CD use GitHub Actions (mirrors) or stay GitLab-only?")
      (context . "GitHub has broader ecosystem; GitLab is canonical source")
      (options . ("GitLab CI only" "Mirror to GitHub with Actions" "Both"))))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; CRITICAL NEXT ACTIONS
    ;; ═══════════════════════════════════════════════════════════════════

    (critical-next
     ((priority . 1)
      (action . "Publish to crates.io")
      (project . "crates-io")
      (command . "cargo publish")
      (deadline . #f))

     ((priority . 2)
      (action . "Create GitLab release with binaries")
      (project . "gitlab-release")
      (command . "manual via GitLab UI or API")
      (deadline . #f))

     ((priority . 3)
      (action . "Implement Zig FFI wrapper")
      (project . "zig-ffi")
      (command . "create zig/bunsenite.zig")
      (deadline . #f))

     ((priority . 4)
      (action . "Announce v0.1.0 on /r/rust")
      (project . "community")
      (command . "post to reddit.com/r/rust")
      (deadline . #f))

     ((priority . 5)
      (action . "Complete Deno bindings")
      (project . "deno-bindings")
      (command . "finalize bindings/deno/")
      (deadline . #f)))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; LONG TERM ROADMAP
    ;; ═══════════════════════════════════════════════════════════════════
    ;;
    ;; v0.1.x — Current (Bronze Tier)
    ;;   - Rust core with nickel-lang-core 0.9.1
    ;;   - WASM bindings
    ;;   - CLI (parse, validate, info)
    ;;   - 8 tests, RSR Bronze compliant
    ;;
    ;; v0.2.0 — FFI Complete
    ;;   - Zig C ABI layer implemented
    ;;   - Deno bindings complete
    ;;   - Rescript bindings complete
    ;;   - FFI stability testing
    ;;
    ;; v0.3.0 — Developer Experience
    ;;   - Improved error messages (miette)
    ;;   - Watch mode
    ;;   - Interactive REPL
    ;;   - Performance benchmarks
    ;;
    ;; v0.4.0 — Validation & Schema
    ;;   - Schema definition DSL
    ;;   - Config validation
    ;;   - JSON Schema export
    ;;
    ;; v1.0.0 — Production Ready (Silver Tier Target)
    ;;   - All planned bindings complete
    ;;   - 90%+ test coverage
    ;;   - Security audit passed
    ;;   - LSP for IDE integration
    ;;   - Comprehensive documentation
    ;;   - Stable API guarantee
    ;;
    ;; v2.0.0 — Ecosystem (Future)
    ;;   - Plugin system
    ;;   - Bunsenite Server (HTTP/GraphQL API)
    ;;   - Migration tools (JSON/YAML/TOML to Nickel)
    ;;   - Config diffing
    ;;   - Distributed configuration (CRDT-based)

    ;; ═══════════════════════════════════════════════════════════════════
    ;; HISTORY / VELOCITY
    ;; ═══════════════════════════════════════════════════════════════════

    (history
     ((date . "2025-11-22")
      (milestone . "v0.1.0 code complete")
      (completed . (rust-core wasm-bindings cli))
      (notes . "Initial release, RSR Bronze tier achieved"))

     ((date . "2025-12-08")
      (milestone . "STATE.scm created")
      (completed . ())
      (notes . "Project state documented for AI-assisted development")))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; SESSION TRACKING
    ;; ═══════════════════════════════════════════════════════════════════

    (files-created-this-session
     ("STATE.scm"))

    (files-modified-this-session
     ())

    (context-notes
     "Bunsenite v0.1.0 is code complete with Rust core and WASM bindings.
      Primary blockers are: (1) Zig FFI layer not implemented, blocking Deno/Rescript;
      (2) Publishing to crates.io and GitLab releases not yet done.
      The project follows RSR Bronze tier standards and TPCF Perimeter 3 governance.
      Key architectural decision: Zig provides stable C ABI to isolate consumers from Rust ABI changes.")))

;;; ═══════════════════════════════════════════════════════════════════════
;;; QUERY FUNCTIONS (for minikanren-style queries)
;;; ═══════════════════════════════════════════════════════════════════════

(define (blocked-projects state)
  "Return all projects with status 'blocked"
  (filter (lambda (p) (eq? (assoc-ref p 'status) 'blocked))
          (assoc-ref state 'projects)))

(define (in-progress-projects state)
  "Return all projects with status 'in-progress"
  (filter (lambda (p) (eq? (assoc-ref p 'status) 'in-progress))
          (assoc-ref state 'projects)))

(define (completion-percentage state)
  "Calculate overall completion across all projects"
  (let* ((projects (assoc-ref state 'projects))
         (total (length projects))
         (sum (apply + (map (lambda (p) (assoc-ref p 'completion)) projects))))
    (/ sum total)))

(define (dependencies-for project-id state)
  "Get dependencies for a given project"
  (let ((project (find (lambda (p) (eq? (assoc-ref p 'id) project-id))
                       (assoc-ref state 'projects))))
    (if project
        (assoc-ref project 'depends)
        '())))

;;; ═══════════════════════════════════════════════════════════════════════
;;; VISUALIZATION (Mermaid diagram generation)
;;; ═══════════════════════════════════════════════════════════════════════

;; To generate a Mermaid dependency graph:
;;
;; ```mermaid
;; graph TD
;;     rust-core[Rust Core 100%]
;;     wasm-bindings[WASM Bindings 100%]
;;     cli[CLI 100%]
;;     zig-ffi[Zig FFI 10%]
;;     deno-bindings[Deno Bindings 30%]
;;     rescript-bindings[Rescript Bindings 20%]
;;
;;     rust-core --> wasm-bindings
;;     rust-core --> cli
;;     rust-core --> zig-ffi
;;     zig-ffi --> deno-bindings
;;     zig-ffi --> rescript-bindings
;;
;;     style rust-core fill:#90EE90
;;     style wasm-bindings fill:#90EE90
;;     style cli fill:#90EE90
;;     style zig-ffi fill:#FFB6C1
;;     style deno-bindings fill:#FFB6C1
;;     style rescript-bindings fill:#FFB6C1
;; ```

;;; End of STATE.scm
