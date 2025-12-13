;;; STATE.scm — Bunsenite Project State Checkpoint
;;; Format: https://github.com/hyperpolymath/state.scm
;;;
;;; Download this file at end of each session!
;;; At start of next conversation, upload it.

(define state
  '((metadata
     (version . "1.0.2")
     (created . "2025-12-08")
     (updated . "2025-12-12")
     (generator . "claude-opus-4"))

    (user
     (name . "hyperpolymath")
     (roles . (maintainer architect))
     (languages . (rust zig rescript scheme))
     (tools . (cargo just wasm-pack deno nix guix))
     (values . (type-safety memory-safety offline-first emotional-safety))
     (preferences . (deno-over-npm rescript-over-typescript no-shell-scripts)))

    (session
     (conversation-id . "claude/bunsenite-v1-release")
     (messages . 1)
     (token-limit . 200000)
     (tokens-remaining . "~180000"))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; CURRENT POSITION
    ;; ═══════════════════════════════════════════════════════════════════

    (focus
     (project . "bunsenite")
     (phase . "release")
     (milestone . "v1.0.0 ready for publishing")
     (blocking . ()))

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
      (notes . "nickel-lang-core 0.9.1 integration, miette error diagnostics")
      (next-action . "maintenance only"))

     ((id . "wasm-bindings")
      (name . "WebAssembly Bindings")
      (status . complete)
      (completion . 100)
      (category . bindings)
      (phase . "released")
      (depends . (rust-core))
      (notes . "wasm-bindgen integration, ~95% native speed")
      (next-action . "none"))

     ((id . "cli")
      (name . "Command Line Interface")
      (status . complete)
      (completion . 100)
      (category . tooling)
      (phase . "released")
      (depends . (rust-core))
      (notes . "parse, validate, watch, repl, schema, info commands")
      (next-action . "none"))

     ;; ─────────────────────────────────────────────────────────────────
     ;; FFI LAYER (COMPLETE)
     ;; ─────────────────────────────────────────────────────────────────
     ((id . "zig-ffi")
      (name . "Zig C ABI Layer")
      (status . complete)
      (completion . 100)
      (category . ffi)
      (phase . "released")
      (depends . (rust-core))
      (notes . "Stable C ABI wrapper in zig/bunsenite.zig")
      (next-action . "none"))

     ((id . "deno-bindings")
      (name . "Deno FFI Bindings")
      (status . complete)
      (completion . 100)
      (category . bindings)
      (phase . "released")
      (depends . (zig-ffi))
      (notes . "Uses Deno.dlopen, NOT plain TypeScript")
      (next-action . "none"))

     ((id . "rescript-bindings")
      (name . "Rescript C FFI Bindings")
      (status . complete)
      (completion . 100)
      (category . bindings)
      (phase . "released")
      (depends . (zig-ffi))
      (notes . "ReScript FFI with npm package for distribution")
      (next-action . "none"))

     ;; ─────────────────────────────────────────────────────────────────
     ;; V1.0 FEATURES (COMPLETE)
     ;; ─────────────────────────────────────────────────────────────────
     ((id . "error-messages")
      (name . "Improved Error Messages")
      (status . complete)
      (completion . 100)
      (category . core)
      (phase . "released")
      (depends . (rust-core))
      (notes . "miette 7.0 with fancy feature for pretty errors")
      (next-action . "none"))

     ((id . "schema-validation")
      (name . "Configuration Schema Validation")
      (status . complete)
      (completion . 100)
      (category . core)
      (phase . "released")
      (depends . (rust-core))
      (notes . "jsonschema crate, CLI schema command")
      (next-action . "none"))

     ((id . "watch-mode")
      (name . "Watch Mode / Auto-Reload")
      (status . complete)
      (completion . 100)
      (category . tooling)
      (phase . "released")
      (depends . (cli))
      (notes . "notify 6.1 crate, bunsenite watch command")
      (next-action . "none"))

     ((id . "repl")
      (name . "Interactive REPL")
      (status . complete)
      (completion . 100)
      (category . tooling)
      (phase . "released")
      (depends . (rust-core))
      (notes . "rustyline 14.0, bunsenite repl command")
      (next-action . "none"))

     ;; ─────────────────────────────────────────────────────────────────
     ;; PUBLISHING (IN PROGRESS)
     ;; ─────────────────────────────────────────────────────────────────
     ((id . "crates-io")
      (name . "Publish to crates.io")
      (status . in-progress)
      (completion . 80)
      (category . infra)
      (phase . "ready")
      (depends . (rust-core))
      (notes . "Needs CARGO_REGISTRY_TOKEN secret")
      (next-action . "add secret and run cargo publish"))

     ((id . "github-release")
      (name . "Create GitHub Release")
      (status . complete)
      (completion . 100)
      (category . infra)
      (phase . "released")
      (depends . (rust-core))
      (notes . "v1.0.2 released with all platform binaries")
      (next-action . "none"))

     ((id . "package-managers")
      (name . "Submit to Package Managers")
      (status . in-progress)
      (completion . 60)
      (category . infra)
      (phase . "partially-complete")
      (depends . (github-release))
      (notes . "Homebrew tap updated. AUR PKGBUILDs ready. Flathub, nixpkgs, Chocolatey, winget, Scoop pending.")
      (next-action . "submit to remaining package managers"))

     ;; ─────────────────────────────────────────────────────────────────
     ;; FUTURE WORK (PLANNED)
     ;; ─────────────────────────────────────────────────────────────────
     ((id . "tui")
      (name . "Terminal User Interface")
      (status . paused)
      (completion . 0)
      (category . tooling)
      (phase . "planned")
      (depends . (cli))
      (notes . "ratatui/crossterm for interactive config editing")
      (next-action . "design TUI interface after v1.0"))

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
    ;; RSR COMPLIANCE
    ;; ═══════════════════════════════════════════════════════════════════

    (compliance
     (rsr-tier . "bronze")
     (tpcf-perimeter . 3)
     (offline-first . #t)
     (type-safety . "compile-time")
     (memory-safety . "rust-ownership")
     (no-typescript . #t)  ; Deno FFI uses .ts but is Deno.dlopen, not plain TS
     (no-npm . #t)         ; ReScript package.json is for npm publishing only
     (no-bun . #t)         ; DO NOT use bun:ffi - always use Deno.dlopen
     (no-node . #t)        ; DO NOT use ffi-napi - always use Deno.dlopen
     (no-python . #t)
     (no-shell-scripts . #t)
     (justfile . #t))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; CI/CD NOTES
    ;; ═══════════════════════════════════════════════════════════════════
    ;;
    ;; Build times (per platform):
    ;;   - Rust compilation: ~7-10 minutes (with --features full)
    ;;   - Zig FFI build: ~30 seconds
    ;;   - Packaging/upload: ~1 minute
    ;;   - Total: ~10-15 minutes per platform
    ;;
    ;; Optimization opportunities:
    ;;   - Enable Cargo caching (configured but GitHub cache sometimes fails)
    ;;   - Consider fewer targets if not all are needed
    ;;   - Cross-compilation (aarch64-linux) uses Docker and is slower
    ;;
    ;; Build times do NOT affect end users - they download pre-built binaries.
    ;; These times are CI/CD only (release workflow on tag push).

    (cicd
     (rust-compile-time . "7-10 minutes")
     (zig-ffi-time . "30 seconds")
     (total-per-platform . "10-15 minutes")
     (targets . (x86_64-unknown-linux-gnu
                 aarch64-unknown-linux-gnu
                 x86_64-apple-darwin
                 aarch64-apple-darwin
                 x86_64-pc-windows-msvc))
     (zig-ffi-platforms . (x86_64-unknown-linux-gnu
                           x86_64-apple-darwin
                           aarch64-apple-darwin))
     (notes . "Zig FFI skipped for cross-compiled (aarch64-linux) and Windows targets"))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; ROUTE TO V1.0.0 RELEASE
    ;; ═══════════════════════════════════════════════════════════════════
    ;;
    ;; Phase 1: Final Verification (current)
    ;;   1. RSR antipattern workflow fix (Deno .ts exclusion)
    ;;   2. Update STATE.scm and CLAUDE.md
    ;;   3. Create wiki page
    ;;
    ;; Phase 2: Release
    ;;   4. Create v1.0.0 tag
    ;;   5. Push to trigger release workflow
    ;;   6. Verify artifacts published
    ;;
    ;; Phase 3: Distribution
    ;;   7. Submit to AUR
    ;;   8. Submit to Homebrew
    ;;   9. Submit to nixpkgs
    ;;  10. Submit to Flathub
    ;;  11. Submit to Chocolatey
    ;;  12. Submit to winget
    ;;  13. Submit to Scoop

    ;; ═══════════════════════════════════════════════════════════════════
    ;; CRITICAL NEXT ACTIONS
    ;; ═══════════════════════════════════════════════════════════════════

    (critical-next
     ((priority . 1)
      (action . "Submit AUR packages")
      (project . "package-managers")
      (command . "git clone ssh://aur@aur.archlinux.org/bunsenite-bin.git")
      (deadline . #f))

     ((priority . 2)
      (action . "Submit to nixpkgs")
      (project . "package-managers")
      (command . "PR to nixpkgs repo")
      (deadline . #f))

     ((priority . 3)
      (action . "Submit remaining package managers")
      (project . "package-managers")
      (command . "Flathub, Chocolatey, winget, Scoop")
      (deadline . #f)))

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
      (notes . "Project state documented for AI-assisted development"))

     ((date . "2025-12-12")
      (milestone . "v1.0.0 complete")
      (completed . (zig-ffi deno-bindings rescript-bindings error-messages
                    schema-validation watch-mode repl))
      (notes . "All MVP features complete, ready for release"))

     ((date . "2025-12-13")
      (milestone . "v1.0.2 released")
      (completed . (github-release homebrew-tap aur-pkgbuild))
      (notes . "Released to GitHub, Homebrew tap updated, AUR PKGBUILDs created")))

    ;; ═══════════════════════════════════════════════════════════════════
    ;; SESSION TRACKING
    ;; ═══════════════════════════════════════════════════════════════════

    (files-modified-this-session
     (".github/workflows/*.yml"  ; 17 workflow files fixed for OpenSSF Scorecard
      "STATE.scm"
      "CLAUDE.md"))

    (openssf-scorecard-fixes
     ((date . "2025-12-13")
      (files-fixed . 17)
      (fixes-applied . ("permissions: read-all"
                        "SHA-pinned GitHub Actions"
                        "SPDX-License-Identifier headers"))))

    (context-notes
     "Bunsenite v1.0.0 is complete with all planned features:
      - Rust core with nickel-lang-core 0.9.1
      - Zig FFI layer for stable C ABI
      - Deno bindings (Deno.dlopen, not plain TypeScript)
      - ReScript bindings
      - WASM bindings
      - CLI with parse, validate, watch, repl, schema commands
      - miette error diagnostics
      - RSR Bronze tier compliant, TPCF Perimeter 3
      Ready for v1.0.0 tag and package manager submissions.")))

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
;;     zig-ffi[Zig FFI 100%]
;;     deno-bindings[Deno Bindings 100%]
;;     rescript-bindings[Rescript Bindings 100%]
;;     watch-mode[Watch Mode 100%]
;;     repl[REPL 100%]
;;     schema[Schema Validation 100%]
;;
;;     rust-core --> wasm-bindings
;;     rust-core --> cli
;;     rust-core --> zig-ffi
;;     zig-ffi --> deno-bindings
;;     zig-ffi --> rescript-bindings
;;     cli --> watch-mode
;;     rust-core --> repl
;;     rust-core --> schema
;;
;;     style rust-core fill:#90EE90
;;     style wasm-bindings fill:#90EE90
;;     style cli fill:#90EE90
;;     style zig-ffi fill:#90EE90
;;     style deno-bindings fill:#90EE90
;;     style rescript-bindings fill:#90EE90
;;     style watch-mode fill:#90EE90
;;     style repl fill:#90EE90
;;     style schema fill:#90EE90
;; ```

;;; End of STATE.scm
