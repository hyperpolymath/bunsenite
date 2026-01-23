;; SPDX-License-Identifier: PMPL-1.0-or-later
;; STATE.scm - Current project state

(define project-state
  `((metadata
      ((version . "0.2.0")
       (schema-version . "1")
       (created . "2025-01-08T00:00:00+00:00")
       (updated . "2026-01-23T19:00:00+00:00")
       (project . "bunsenite")
       (repo . "bunsenite")))
    (current-position
      ((phase . "Active development - FFI bindings")
       (overall-completion . 80)
       (components
         ((rust-core . ((status . "working") (completion . 90)
                        (notes . "Nickel parser, 20 Rust source files")))
          (c-abi . ((status . "working") (completion . 80)
                    (notes . "Zig-based C FFI layer")))
          (deno-bindings . ((status . "working") (completion . 70)
                            (notes . "3 JS/TS files")))
          (rescript-bindings . ((status . "working") (completion . 95)
                                (notes . "3 ReScript files: bindings, tests, examples")))
          (wasm-target . ((status . "working") (completion . 75)
                          (notes . "Browser and universal use")))))
       (working-features . (
         "Nickel configuration file parsing"
         "Rust core library (20 files)"
         "C ABI via Zig"
         "Deno FFI bindings"
         "ReScript bindings (partial)"
         "WASM compilation target"))))
    (route-to-mvp
      ((milestones
        ((v0.2 . ((items . (
          "✓ Rust core parser"
          "✓ C ABI layer (Zig)"
          "✓ Deno bindings"
          "✓ ReScript bindings completion (tests + examples)"
          "⧖ WASM optimization"
          "○ Documentation and examples")))))))
    (blockers-and-issues
      ((critical . ())
       (high . ())
       (medium . ())
       (low . ("Documentation examples"))))
    (critical-next-actions
      ((immediate . ("Run and verify ReScript tests"))
       (this-week . ("Add usage examples"))
       (this-month . ("WASM optimization and benchmarks"))))))
