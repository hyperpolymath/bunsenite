K9!
# SPDX-License-Identifier: PMPL-1.0-or-later
# Bunsenite Configuration Validator
#
# This K9 component validates Nickel configuration files used in the Bunsenite
# project itself - dogfooding! It checks test fixtures, example configs, and
# ensures they conform to expected schemas.

leash = 'Yard  # Nickel evaluation only, no side effects

pedigree = {
  schema_version = "1.0.0",
  component_type = "config-validator",
  author = "Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>",
  description = "Validates Nickel configurations in Bunsenite test suite",
  created = "2026-01-30",
  k9_spec_version = "1.0.0",
}

# Configuration paths and validation rules
config = {
  # Directories containing Nickel files to validate
  config_dirs | Array String = [
    "tests/fixtures",
    "examples",
    "benches/configs",
  ],

  # Expected schemas for different config types
  schemas = {
    # Example application config schema
    app_config = {
      name | String,
      version | String
        | std.string.is_match "^[0-9]+\\.[0-9]+\\.[0-9]+$",
      port | Number
        | std.number.is_nat
        | std.number.between 1024 65535,
      features | Array String | default = [],
      metadata | { _ : Dyn } | default = {},
    },

    # Benchmark configuration schema
    benchmark_config = {
      name | String,
      iterations | Number
        | std.number.is_nat
        | std.number.greater_or_eq 1,
      input_size | Number | std.number.is_nat,
      warmup_iterations | Number
        | std.number.is_nat
        | default = 10,
    },

    # Test fixture schema
    test_fixture = {
      description | String,
      input | String,
      expected_output | Dyn,
      should_fail | Bool | default = false,
    },
  },

  # Validation rules for all configs
  validation_rules = {
    # All configs must be valid Nickel
    valid_nickel = true,

    # No empty string values
    no_empty_strings = true,

    # Port numbers must be in valid range
    valid_ports = true,

    # Version strings must follow semver
    semver_versions = true,
  },
}

# Validation contracts
validation = {
  # Example: Validate app config structure
  validate_app_config = fun config_value =>
    let is_valid_name = std.string.length config_value.name > 0 in
    let is_valid_version =
      std.string.is_match "^[0-9]+\\.[0-9]+\\.[0-9]+" config_value.version
    in
    let is_valid_port =
      config_value.port >= 1024 && config_value.port <= 65535
    in
    is_valid_name && is_valid_version && is_valid_port
    | doc "App config must have non-empty name, semver version, and valid port",

  # Check that all test fixtures have required fields
  validate_test_fixture = fun fixture =>
    let has_description = std.string.length fixture.description > 0 in
    let has_input = std.string.length fixture.input > 0 in
    has_description && has_input
    | doc "Test fixture must have description and input",

  # Validate benchmark config
  validate_benchmark = fun bench =>
    let has_positive_iterations = bench.iterations > 0 in
    let has_positive_input_size = bench.input_size > 0 in
    has_positive_iterations && has_positive_input_size
    | doc "Benchmark must have positive iterations and input_size",
}

# Example validated configurations (used in tests)
examples = {
  valid_app_config = {
    name = "bunsenite-example",
    version = "1.2.3",
    port = 8080,
    features = ["wasm", "ffi-bindings"],
    metadata = {
      author = "Jonathan D.A. Jewell",
      license = "PMPL-1.0-or-later",
    },
  } | config.schemas.app_config,

  valid_benchmark = {
    name = "parse_large_config",
    iterations = 1000,
    input_size = 10000,
    warmup_iterations = 50,
  } | config.schemas.benchmark_config,

  valid_test_fixture = {
    description = "Parse simple object",
    input = "{ name = \"test\", value = 42 }",
    expected_output = { name = "test", value = 42 },
    should_fail = false,
  } | config.schemas.test_fixture,
}

# Dogfooding note: This K9 component validates Nickel configs using Nickel
# itself, demonstrating Bunsenite's purpose - parsing and validating Nickel!
metadata = {
  dogfooding_note = "This K9 component is itself a Nickel configuration that validates other Nickel configurations, demonstrating the circular nature of configuration validation.",

  usage_example = "
    # In Bunsenite tests, import this K9 component:
    let k9_validator = import \"validate-nickel-configs.k9.ncl\" in
    let my_config = { name = \"test\", version = \"1.0.0\", port = 3000 } in
    k9_validator.validation.validate_app_config my_config
  ",
}
