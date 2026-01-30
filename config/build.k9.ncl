# SPDX-License-Identifier: PMPL-1.0-or-later
K9!
leash = 'Yard  # Validation only, no I/O

pedigree = {
  schema_version = "1.0.0",
  component_type = "rust-build-config",
  tool = "bunsenite",
  validation_level = "strict",
  description = "Self-validating Cargo build configuration for Bunsenite"
}

# Cargo build configuration with Nickel contracts
config | {
  package | {
    name | String,
    version | String,
    edition | String,
    rust_version | String,
    license | String,
    ..
  },

  profile | {
    release | {
      opt_level | [| '0, '1, '2, '3, 's, 'z |],
      lto | [| 'Off, 'Thin, 'Fat |] | Bool,
      codegen_units | Number,
      strip | Bool,
      ..
    },
    dev | {
      opt_level | [| '0, '1, '2, '3 |],
      ..
    },
    ..
  },

  features | {
    default | Array String,
    full | Array String,
    ..
  },
  ..
} = {
  package = {
    name = "bunsenite",
    version = "0.1.0",
    edition = "2021",
    rust_version = "1.70",
    license = "PMPL-1.0-or-later",
    authors = ["Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>"],
    description = "Nickel language tooling and utilities",
    repository = "https://github.com/hyperpolymath/bunsenite",
  },

  profile = {
    release = {
      opt_level = '3,
      lto = 'Thin,
      codegen_units = 1,
      strip = true,
    },
    dev = {
      opt_level = '0,
    },
  },

  features = {
    default = ["cli"],
    full = ["cli", "wasm", "ffi"],
  },

  # Nickel contracts enforce validity
  package.edition
    | std.contract.from_predicate
        (fun e => std.array.elem e ["2015", "2018", "2021", "2024"]),

  package.version
    | std.contract.from_predicate
        (fun v => std.string.is_match "^[0-9]+\\.[0-9]+\\.[0-9]+(-[a-z0-9]+)?(\\+[a-z0-9]+)?$" v),

  package.license
    | std.contract.from_predicate
        (fun l => std.array.elem l [
          "PMPL-1.0-or-later",
          "AGPL-3.0-or-later",
          "MIT",
          "Apache-2.0"
        ]),

  profile.release.codegen_units
    | std.number.Positive
    | std.contract.from_predicate (fun u => u >= 1 && u <= 256),
}

# Build commands based on profile
build_commands = {
  dev = "cargo build",
  release = "cargo build --release",
  check = "cargo check --all-targets --all-features",
  test = "cargo test --all-features",
  bench = "cargo bench --all-features",
  doc = "cargo doc --no-deps --all-features",
}
