//! Bunsenite CLI
//!
//! Command-line interface for parsing and evaluating Nickel configuration files

use bunsenite::{NickelLoader, VERSION};
use clap::{Parser, Subcommand};
use miette::IntoDiagnostic;
use std::path::PathBuf;
use std::process;

#[derive(Parser)]
#[command(
    name = "bunsenite",
    version = VERSION,
    about = "Nickel configuration file parser with multi-language FFI bindings",
    long_about = "Bunsenite is a Nickel configuration file parser with multi-language FFI bindings.\n\
                  It provides a Rust core library with a stable C ABI layer (via Zig) that enables\n\
                  bindings for Deno (JavaScript/TypeScript), Rescript, and WebAssembly.\n\n\
                  RSR Compliance: Bronze Tier | TPCF Perimeter: 3 (Community Sandbox)"
)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,

    /// Enable verbose output
    #[arg(short, long, global = true)]
    verbose: bool,
}

#[derive(Subcommand)]
enum Commands {
    /// Parse and evaluate a Nickel configuration file
    Parse {
        /// Path to the Nickel configuration file
        #[arg(value_name = "FILE")]
        file: PathBuf,

        /// Pretty-print the output JSON
        #[arg(short, long)]
        pretty: bool,
    },

    /// Validate a Nickel configuration without evaluating it
    Validate {
        /// Path to the Nickel configuration file
        #[arg(value_name = "FILE")]
        file: PathBuf,
    },

    /// Watch a file for changes and re-evaluate on save
    #[cfg(feature = "watch")]
    Watch {
        /// Path to the Nickel configuration file to watch
        #[arg(value_name = "FILE")]
        file: PathBuf,

        /// Pretty-print the output JSON
        #[arg(short, long)]
        pretty: bool,
    },

    /// Start an interactive REPL for Nickel expressions
    #[cfg(feature = "repl")]
    Repl,

    /// Validate a Nickel config against a JSON schema
    #[cfg(feature = "schema")]
    Schema {
        /// Path to the Nickel configuration file
        #[arg(value_name = "CONFIG")]
        config: PathBuf,

        /// Path to the JSON schema file
        #[arg(value_name = "SCHEMA")]
        schema: PathBuf,
    },

    /// Show version and compliance information
    Info,
}

fn main() {
    // Install miette's pretty error handler
    miette::set_hook(Box::new(|_| {
        Box::new(
            miette::MietteHandlerOpts::new()
                .terminal_links(true)
                .unicode(true)
                .context_lines(2)
                .build(),
        )
    }))
    .ok();

    let cli = Cli::parse();

    let result = match cli.command {
        Some(Commands::Parse { file, pretty }) => handle_parse(file, pretty, cli.verbose),
        Some(Commands::Validate { file }) => handle_validate(file, cli.verbose),
        #[cfg(feature = "watch")]
        Some(Commands::Watch { file, pretty }) => handle_watch(file, pretty, cli.verbose),
        #[cfg(feature = "repl")]
        Some(Commands::Repl) => handle_repl(cli.verbose),
        #[cfg(feature = "schema")]
        Some(Commands::Schema { config, schema }) => handle_schema(config, schema, cli.verbose),
        Some(Commands::Info) => {
            handle_info();
            Ok(())
        }
        None => {
            // No command specified, show help
            println!("{}", get_help_text());
            Ok(())
        }
    };

    if let Err(e) = result {
        // Use miette's error reporting
        eprintln!("{:?}", miette::Report::new(e));
        process::exit(1);
    }
}

fn handle_parse(file: PathBuf, pretty: bool, verbose: bool) -> bunsenite::Result<()> {
    if verbose {
        eprintln!("Parsing file: {}", file.display());
    }

    let loader = NickelLoader::new().with_verbose(verbose);
    let result = loader.parse_file(&file)?;

    if pretty {
        println!("{}", serde_json::to_string_pretty(&result).unwrap());
    } else {
        println!("{}", serde_json::to_string(&result).unwrap());
    }

    if verbose {
        eprintln!("✓ Successfully parsed and evaluated");
    }

    Ok(())
}

fn handle_validate(file: PathBuf, verbose: bool) -> bunsenite::Result<()> {
    if verbose {
        eprintln!("Validating file: {}", file.display());
    }

    let source = std::fs::read_to_string(&file)?;
    let name = file
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("unknown.ncl");

    let loader = NickelLoader::new().with_verbose(verbose);
    loader.validate(&source, name)?;

    println!("✓ Configuration is valid");

    Ok(())
}

/// Watch a file for changes and re-parse on save
#[cfg(feature = "watch")]
fn handle_watch(file: PathBuf, pretty: bool, verbose: bool) -> bunsenite::Result<()> {
    use notify::{Config, RecommendedWatcher, RecursiveMode, Watcher};
    use std::sync::mpsc::channel;
    use std::time::Duration;

    println!(
        "Watching {} for changes (Ctrl+C to stop)...",
        file.display()
    );

    // Initial parse
    if let Err(e) = handle_parse(file.clone(), pretty, verbose) {
        eprintln!("{:?}", miette::Report::new(e));
    }

    let (tx, rx) = channel();

    let mut watcher = RecommendedWatcher::new(
        move |res| {
            if let Ok(event) = res {
                let _ = tx.send(event);
            }
        },
        Config::default().with_poll_interval(Duration::from_millis(500)),
    )
    .map_err(|e| bunsenite::Error::watch_error(e.to_string()))?;

    watcher
        .watch(&file, RecursiveMode::NonRecursive)
        .map_err(|e| bunsenite::Error::watch_error(e.to_string()))?;

    loop {
        match rx.recv() {
            Ok(event) => {
                if event.kind.is_modify() {
                    println!("\n--- File changed, re-parsing... ---\n");
                    if let Err(e) = handle_parse(file.clone(), pretty, verbose) {
                        eprintln!("{:?}", miette::Report::new(e));
                    }
                }
            }
            Err(e) => {
                return Err(bunsenite::Error::watch_error(e.to_string()));
            }
        }
    }
}

/// Validate a Nickel config against a JSON schema
#[cfg(feature = "schema")]
fn handle_schema(config: PathBuf, schema: PathBuf, verbose: bool) -> bunsenite::Result<()> {
    use bunsenite::SchemaValidator;

    if verbose {
        eprintln!(
            "Validating {} against schema {}",
            config.display(),
            schema.display()
        );
    }

    let loader = NickelLoader::new().with_verbose(verbose);
    let result = loader.parse_file(&config)?;

    let validator = SchemaValidator::from_file(&schema)?;
    validator.validate(&result)?;

    println!("✓ Configuration matches schema");

    Ok(())
}

/// Interactive REPL for Nickel expressions
#[cfg(feature = "repl")]
fn handle_repl(verbose: bool) -> bunsenite::Result<()> {
    use rustyline::error::ReadlineError;
    use rustyline::DefaultEditor;

    println!("Bunsenite v{} - Nickel REPL", VERSION);
    println!("Type Nickel expressions to evaluate. Use :help for commands, :quit to exit.\n");

    let mut rl = DefaultEditor::new().map_err(|e| bunsenite::Error::internal(e.to_string()))?;
    let loader = NickelLoader::new().with_verbose(verbose);

    loop {
        match rl.readline("nickel> ") {
            Ok(line) => {
                let trimmed = line.trim();
                if trimmed.is_empty() {
                    continue;
                }

                // Handle REPL commands
                match trimmed {
                    ":quit" | ":q" | ":exit" => {
                        println!("Goodbye!");
                        break;
                    }
                    ":help" | ":h" => {
                        println!("REPL Commands:");
                        println!("  :help, :h     Show this help");
                        println!("  :quit, :q     Exit the REPL");
                        println!("  :clear, :c    Clear the screen");
                        println!("  :version, :v  Show version info");
                        println!("\nEnter any Nickel expression to evaluate it.");
                        continue;
                    }
                    ":clear" | ":c" => {
                        print!("\x1B[2J\x1B[1;1H");
                        continue;
                    }
                    ":version" | ":v" => {
                        println!("Bunsenite v{}", VERSION);
                        continue;
                    }
                    _ => {}
                }

                let _ = rl.add_history_entry(&line);

                match loader.parse(&trimmed, "<repl>") {
                    Ok(result) => {
                        println!("{}", serde_json::to_string_pretty(&result).unwrap());
                    }
                    Err(e) => {
                        eprintln!("{:?}", miette::Report::new(e));
                    }
                }
            }
            Err(ReadlineError::Interrupted) => {
                println!("^C");
                continue;
            }
            Err(ReadlineError::Eof) => {
                println!("Goodbye!");
                break;
            }
            Err(e) => {
                return Err(bunsenite::Error::internal(e.to_string()));
            }
        }
    }

    Ok(())
}

fn handle_info() {
    println!("Bunsenite v{}", VERSION);
    println!();
    println!("A Nickel configuration file parser with multi-language FFI bindings");
    println!();
    println!("Features:");
    println!("  • Type Safety: Compile-time guarantees via Rust's type system");
    println!("  • Memory Safety: Rust ownership model, zero unsafe blocks");
    println!("  • Offline-First: Works completely air-gapped, no network dependencies");
    println!("  • Multi-Language: FFI bindings for Deno, Rescript, and WASM");
    println!();
    println!("Standards Compliance:");
    println!("  • RSR Framework: Bronze Tier");
    println!("  • TPCF Perimeter: 3 (Community Sandbox)");
    println!("  • License: Dual PMPL-1.0 + Palimpsest 0.8");
    println!();
    println!("Repository: https://gitlab.com/campaign-for-cooler-coding-and-programming/bunsenite");
    println!();
}

fn get_help_text() -> String {
    let mut commands = r#"COMMANDS:
    parse       Parse and evaluate a Nickel configuration file
    validate    Validate a Nickel configuration without evaluating it"#
        .to_string();

    #[cfg(feature = "watch")]
    {
        commands.push_str("\n    watch       Watch a file and re-evaluate on changes");
    }

    #[cfg(feature = "repl")]
    {
        commands.push_str("\n    repl        Start an interactive Nickel REPL");
    }

    #[cfg(feature = "schema")]
    {
        commands.push_str("\n    schema      Validate config against JSON schema");
    }

    commands.push_str(
        r#"
    info        Show version and compliance information
    help        Print this message or the help of the given subcommand(s)"#,
    );

    let mut examples = r#"EXAMPLES:
    # Parse and evaluate a config file
    bunsenite parse config.ncl

    # Parse with pretty-printed output
    bunsenite parse config.ncl --pretty

    # Validate without evaluating
    bunsenite validate config.ncl"#
        .to_string();

    #[cfg(feature = "watch")]
    {
        examples.push_str(
            r#"

    # Watch for changes
    bunsenite watch config.ncl --pretty"#,
        );
    }

    #[cfg(feature = "repl")]
    {
        examples.push_str(
            r#"

    # Start interactive REPL
    bunsenite repl"#,
        );
    }

    #[cfg(feature = "schema")]
    {
        examples.push_str(
            r#"

    # Validate against JSON schema
    bunsenite schema config.ncl schema.json"#,
        );
    }

    examples.push_str(
        r#"

    # Show info
    bunsenite info"#,
    );

    format!(
        r#"Bunsenite v{VERSION}
Nickel configuration file parser

USAGE:
    bunsenite <COMMAND>

{commands}

OPTIONS:
    -v, --verbose    Enable verbose output
    -h, --help       Print help information
    -V, --version    Print version information

{examples}

For more information, visit:
https://gitlab.com/campaign-for-cooler-coding-and-programming/bunsenite
"#
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cli_info_runs() {
        // Just verify info command doesn't panic
        handle_info();
    }

    #[test]
    fn test_help_text_contains_version() {
        let help = get_help_text();
        assert!(help.contains(VERSION));
    }
}
