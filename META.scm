;; SPDX-License-Identifier: PMPL-1.0
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell

;;; META.scm — Architecture Decisions and Development Practices
;;; bunsenite
;;; Reference: https://github.com/hyperpolymath/META.scm

(define-module (bunsenite meta)
  #:export (architecture-decisions
            development-practices
            design-rationale))

;;;============================================================================
;;; Architecture Decision Records (ADR)
;;; Following MADR format in structured S-expression form
;;;============================================================================

(define architecture-decisions
  '((adr-001
     (title . "Initial Architecture and RSR Compliance")
     (status . "accepted")
     (date . "2025-12-15")
     (context . "> Nickel configuration file parser with multi-language FFI bindings")
     (decision . "Establish foundational architecture following Rhodium Standard Repository guidelines with multi-platform CI/CD, SHA-pinned actions, and SPDX headers")
     (consequences . ("RSR Gold compliance target"
                      "SHA-pinned GitHub Actions for security"
                      "SPDX license headers on all source files"
                      "Multi-platform CI/CD (GitHub, GitLab, Bitbucket)"
                      "OpenSSF Scorecard compliance")))))

;;;============================================================================
;;; Development Practices
;;; Codified standards for this repository
;;;============================================================================

(define development-practices
  '((code-style
     (languages . ("Dockerfile" "Just" "Makefile" "Nix" "ReScript" "Ruby" "Rust" "Scheme" "Shell" "Tcl" "TypeScript" "Zig"))
     (formatter . "auto-detect")
     (linter . "auto-detect")
     (line-length . 100)
     (indent . "spaces")
     (indent-size . 2))

    (security
     (sast . "CodeQL + Semgrep")
     (dependency-scanning . "Dependabot + OSSF Scorecard")
     (credentials . "Environment variables only, never committed")
     (input-validation . "Whitelist + schema validation at boundaries")
     (license-PMPL--1.0 . "PMPL-1.0-or-later"))

    (testing
     (framework . "language-native")
     (coverage-minimum . 70)
     (unit-tests . "Required for business logic")
     (integration-tests . "Required for API boundaries")
     (property-testing . "Where applicable"))

    (versioning
     (scheme . "Semantic Versioning 2.0.0")
     (changelog . "Keep a Changelog format")
     (release-process . "GitHub releases with auto-generated notes"))

    (documentation
     (format . "AsciiDoc preferred, Markdown accepted")
     (api-docs . "Language-native doc comments")
     (adr-location . "META.scm"))

    (branching
     (strategy . "GitHub Flow")
     (main-branch . "main")
     (pr-required . #t))))

;;;============================================================================
;;; Design Rationale
;;; Explains the "why" behind technical choices
;;;============================================================================

(define design-rationale
  '((why-rsr
     "Following Rhodium Standard Repositories (RSR) ensures consistency,
      security, and maintainability across the hyperpolymath ecosystem.
      RSR provides: SHA-pinned actions, SPDX headers, OpenSSF Scorecard
      compliance, and multi-platform CI/CD. This creates a unified
      approach to quality across all repositories.")

    (why-agpl
     "PMPL-1.0-or-later chosen to ensure derivative works remain open
      source while allowing integration with PMPL-1.0/BSD libraries. The
      copyleft provision protects community contributions and ensures
      improvements flow back to the ecosystem.")

    (why-polyglot
     "Language selection based on domain fit: Rust for performance-critical
      paths, Elixir for concurrent services, Julia for numerical computing,
      ReScript for type-safe frontends, Ada/SPARK for formally verified code.
      Each language is chosen for its strengths in its domain.")))

;;; End of META.scm
;; ============================================================================
;; CROSS-PLATFORM STATUS (Added 2025-12-17)
;; ============================================================================

(cross-platform-status
  (generated "2025-12-17")
  (primary-platform "github")
  (gitlab-mirror
    (path "hyperpolymath/bunsenite")
    (url "https://gitlab.com/hyperpolymath/bunsenite")
    (last-gitlab-activity "2025-12-16")
    (sync-status "gh-primary")
    (notes "GitHub slightly newer. Safe to sync GH→GL."))
  
  (reconciliation-instructions
    ";; git remote add gitlab https://gitlab.com/hyperpolymath/bunsenite.git"
    ";; git fetch gitlab && git log gitlab/main --oneline"
    ";; git diff main gitlab/main"
    ";; git merge gitlab/main --allow-unrelated-histories  # if needed")
  
  (action-required "gh-primary"))

