; SPDX-License-Identifier: PMPL-1.0-or-later
; NEUROSYM.scm - Neurosymbolic context for bunsenite
; Media type: application/vnd.neurosym+scm

(neurosym
  (metadata
    (version "1.0.0")
    (schema-version "1.0")
    (created "2026-01-30")
    (updated "2026-01-30"))

  (conceptual-model
    (domain "configuration-management")
    (subdomain "type-safe-configuration-languages")
    (core-concepts
      (concept "nickel-contract"
        (definition "A type specification with validation rules in Nickel")
        (properties "type" "constraints" "default-value" "documentation"))
      (concept "configuration-composition"
        (definition "Merging multiple configuration sources with precedence")
        (purpose "Enable modular, reusable configuration blocks"))
      (concept "lazy-evaluation"
        (definition "Defer evaluation until configuration value is needed")
        (purpose "Support circular references, conditional evaluation"))))

  (semantic-mappings
    (nickel-to-json
      (term "Contract" maps-to "JSON Schema")
      (term "Record" maps-to "JSON Object")
      (term "Array" maps-to "JSON Array"))
    (configuration-concepts
      (term "merge" relates-to "configuration-composition")
      (term "default" relates-to "nickel-contract.default-value")
      (term "priority" relates-to "configuration-composition.precedence")))

  (reasoning-context
    (problem-space
      "How to validate configuration before deployment"
      "How to compose configurations from multiple sources"
      "How to document configuration schemas")
    (solution-patterns
      (pattern "contract-based-validation"
        (problem "Runtime configuration errors are costly")
        (solution "Nickel contracts catch errors at parse/check time"))
      (pattern "gradual-typing"
        (problem "Full typing is too strict for simple configs")
        (solution "Optional contracts - add types where needed"))
      (pattern "merge-semantics"
        (problem "Combining configs from base + overrides is error-prone")
        (solution "Well-defined merge operator with precedence rules"))))

  (inference-rules
    (rule "contract-validation"
      (if "field has contract annotation")
      (then "validate value against contract before use"))
    (rule "lazy-evaluation"
      (if "value references undefined variable")
      (then "defer evaluation until variable is bound"))
    (rule "merge-override"
      (if "field defined in base and override")
      (then "override takes precedence unless force-merge")))

  (knowledge-graph-hints
    (entities
      "Nickel" "bunsenite" "contract" "merge" "lazy-evaluation"
      "Rust" "WASM" "Zig" "ReScript" "configuration-DSL")
    (relationships
      ("bunsenite" implements "Nickel parser")
      ("Nickel" supports "gradual typing")
      ("contract" validates "configuration")
      ("bunsenite" compiles-to "WASM")
      ("bunsenite" provides "C-FFI via Zig"))))
