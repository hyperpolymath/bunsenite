;; bunsenite - Guix Package Definition
;; Run: guix shell -D -f guix.scm

(use-modules (guix packages)
             (guix gexp)
             (guix git-download)
             (guix build-system cargo)
             ((guix licenses) #:prefix license:)
             (gnu packages base))

(define-public bunsenite
  (package
    (name "bunsenite")
    (version "1.0.2")
    (source (local-file "." "bunsenite-checkout"
                        #:recursive? #t
                        #:select? (git-predicate ".")))
    (build-system cargo-build-system)
    (synopsis "Nickel configuration file parser with multi-language FFI bindings")
    (description "Bunsenite provides a Rust core library with a stable C ABI layer (via Zig)
that enables bindings for Deno (JavaScript/TypeScript), ReScript, and WebAssembly
for browser and universal use.")
    (home-page "https://github.com/hyperpolymath/bunsenite")
    (license license:expat)))

;; Return package for guix shell
bunsenite
