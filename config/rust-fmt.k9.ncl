# SPDX-License-Identifier: PMPL-1.0-or-later
K9!
leash = 'Yard  # Validation only, no I/O

pedigree = {
  schema_version = "1.0.0",
  component_type = "rust-formatter-config",
  tool = "bunsenite",
  validation_level = "strict",
  description = "Self-validating Rust formatter configuration for Bunsenite"
}

# Rust formatter configuration with Nickel contracts
config | {
  edition | String,
  max_width | Number,
  hard_tabs | Bool,
  tab_spaces | Number,
  newline_style | [| 'Unix, 'Windows, 'Native |],
  use_small_heuristics | [| 'Default, 'Off, 'Max |],
  indent_style | [| 'Block, 'Visual |],
  wrap_comments | Bool,
  format_code_in_doc_comments | Bool,
  comment_width | Number,
  normalize_comments | Bool,
  format_strings | Bool,
  format_macro_matchers | Bool,
  format_macro_bodies | Bool,
  use_try_shorthand | Bool,
  use_field_init_shorthand | Bool,
  ..
} = {
  # Edition
  edition = "2021",

  # Line width
  max_width = 100,
  comment_width = 80,

  # Indentation
  hard_tabs = false,
  tab_spaces = 4,
  indent_style = 'Block,

  # Line endings
  newline_style = 'Unix,

  # Heuristics
  use_small_heuristics = 'Default,

  # Comments
  wrap_comments = true,
  format_code_in_doc_comments = true,
  normalize_comments = true,

  # Strings and macros
  format_strings = true,
  format_macro_matchers = true,
  format_macro_bodies = true,

  # Syntax shortcuts
  use_try_shorthand = true,
  use_field_init_shorthand = true,

  # Nickel contracts enforce validity
  edition
    | std.contract.from_predicate
        (fun e => std.array.elem e ["2015", "2018", "2021", "2024"]),

  max_width
    | std.number.Positive
    | std.contract.from_predicate (fun w => w >= 80 && w <= 120),

  tab_spaces
    | std.number.Positive
    | std.contract.from_predicate (fun s => s >= 2 && s <= 8),

  comment_width
    | std.number.Positive
    | std.contract.from_predicate (fun w => w >= 60 && w <= max_width),
}

# Export for rustfmt.toml generation
rustfmt_toml = {
  edition = config.edition,
  max_width = config.max_width,
  hard_tabs = config.hard_tabs,
  tab_spaces = config.tab_spaces,
  newline_style = std.string.lowercase (std.to_string config.newline_style),
  use_small_heuristics = std.string.lowercase (std.to_string config.use_small_heuristics),
  indent_style = std.string.lowercase (std.to_string config.indent_style),
  wrap_comments = config.wrap_comments,
  format_code_in_doc_comments = config.format_code_in_doc_comments,
  comment_width = config.comment_width,
  normalize_comments = config.normalize_comments,
  format_strings = config.format_strings,
  format_macro_matchers = config.format_macro_matchers,
  format_macro_bodies = config.format_macro_bodies,
  use_try_shorthand = config.use_try_shorthand,
  use_field_init_shorthand = config.use_field_init_shorthand,
}
