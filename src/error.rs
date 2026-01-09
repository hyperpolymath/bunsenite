//! Error types for Bunsenite
//!
//! This module provides comprehensive error handling for all Bunsenite operations.
//! Errors are designed to be informative and actionable for end users.
//! Uses miette for pretty error output with source context.

use miette::{Diagnostic, SourceSpan};

/// Result type alias for Bunsenite operations
pub type Result<T> = std::result::Result<T, Error>;

/// Bunsenite error types with miette integration for rich diagnostics
#[derive(Debug, thiserror::Error, Diagnostic)]
pub enum Error {
    /// Nickel parsing error
    #[error("Failed to parse Nickel file '{file}'")]
    #[diagnostic(
        code(bunsenite::parse_error),
        help("Check your Nickel syntax. Run 'nickel check' for detailed diagnostics.")
    )]
    ParseError {
        /// Name of the file that failed to parse
        file: String,
        /// Error message from the parser
        message: String,
        /// Source code that caused the error
        #[source_code]
        src: Option<String>,
        /// Location of the error in source
        #[label("error here")]
        span: Option<SourceSpan>,
    },

    /// Nickel evaluation error
    #[error("Failed to evaluate Nickel program '{file}'")]
    #[diagnostic(
        code(bunsenite::eval_error),
        help("Ensure all variables are defined and types match.")
    )]
    EvaluationError {
        /// Name of the file that failed to evaluate
        file: String,
        /// Error message from the evaluator
        message: String,
        /// Source code
        #[source_code]
        src: Option<String>,
        /// Location of the error
        #[label("evaluation failed here")]
        span: Option<SourceSpan>,
    },

    /// Serialization error (converting Nickel values to JSON)
    #[error("Failed to serialize result: {0}")]
    #[diagnostic(
        code(bunsenite::serialization_error),
        help("Ensure the Nickel program produces valid JSON-serializable values.")
    )]
    SerializationError(String),

    /// File I/O error
    #[error("File I/O error: {0}")]
    #[diagnostic(code(bunsenite::io_error), help("Check file permissions and path."))]
    IoError(#[from] std::io::Error),

    /// Invalid input
    #[error("Invalid input: {0}")]
    #[diagnostic(
        code(bunsenite::invalid_input),
        help("Check the input format and try again.")
    )]
    InvalidInput(String),

    /// Watch error
    #[error("Watch error: {0}")]
    #[diagnostic(
        code(bunsenite::watch_error),
        help("Check that the file path is valid and accessible.")
    )]
    WatchError(String),

    /// Internal error (should not happen in normal operation)
    #[error("Internal error: {0}")]
    #[diagnostic(
        code(bunsenite::internal_error),
        url("https://gitlab.com/campaign-for-cooler-coding-and-programming/bunsenite/-/issues"),
        help("This is a bug. Please report it.")
    )]
    Internal(String),
}

impl Error {
    /// Create a new parse error
    pub fn parse_error(file: impl Into<String>, message: impl Into<String>) -> Self {
        Error::ParseError {
            file: file.into(),
            message: message.into(),
            src: None,
            span: None,
        }
    }

    /// Create a new parse error with source context
    pub fn parse_error_with_source(
        file: impl Into<String>,
        message: impl Into<String>,
        src: String,
        offset: usize,
        length: usize,
    ) -> Self {
        Error::ParseError {
            file: file.into(),
            message: message.into(),
            src: Some(src),
            span: Some(SourceSpan::new(offset.into(), length)),
        }
    }

    /// Create a new evaluation error
    pub fn evaluation_error(file: impl Into<String>, message: impl Into<String>) -> Self {
        Error::EvaluationError {
            file: file.into(),
            message: message.into(),
            src: None,
            span: None,
        }
    }

    /// Create a new evaluation error with source context
    pub fn evaluation_error_with_source(
        file: impl Into<String>,
        message: impl Into<String>,
        src: String,
        offset: usize,
        length: usize,
    ) -> Self {
        Error::EvaluationError {
            file: file.into(),
            message: message.into(),
            src: Some(src),
            span: Some(SourceSpan::new(offset.into(), length)),
        }
    }

    /// Create a new serialization error
    pub fn serialization_error(message: impl Into<String>) -> Self {
        Error::SerializationError(message.into())
    }

    /// Create a new invalid input error
    pub fn invalid_input(message: impl Into<String>) -> Self {
        Error::InvalidInput(message.into())
    }

    /// Create a new watch error
    pub fn watch_error(message: impl Into<String>) -> Self {
        Error::WatchError(message.into())
    }

    /// Create a new internal error
    pub fn internal(message: impl Into<String>) -> Self {
        Error::Internal(message.into())
    }

    /// Check if this error is recoverable
    ///
    /// Recoverable errors are those that the user can fix by changing input.
    /// Non-recoverable errors indicate bugs or system issues.
    pub fn is_recoverable(&self) -> bool {
        matches!(
            self,
            Error::ParseError { .. }
                | Error::InvalidInput(_)
                | Error::EvaluationError { .. }
                | Error::WatchError(_)
        )
    }

    /// Get the error message (for compatibility)
    pub fn message(&self) -> &str {
        match self {
            Error::ParseError { message, .. } => message,
            Error::EvaluationError { message, .. } => message,
            Error::SerializationError(msg) => msg,
            Error::IoError(e) => "I/O error",
            Error::InvalidInput(msg) => msg,
            Error::WatchError(msg) => msg,
            Error::Internal(msg) => msg,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_error_creation() {
        let err = Error::parse_error("test.ncl", "syntax error");
        assert!(err.is_recoverable());
    }

    #[test]
    fn test_error_display() {
        let err = Error::parse_error("config.ncl", "unexpected token");
        let msg = format!("{}", err);
        assert!(msg.contains("config.ncl"));
    }

    #[test]
    fn test_recoverable_errors() {
        assert!(Error::parse_error("test", "msg").is_recoverable());
        assert!(Error::invalid_input("msg").is_recoverable());
        assert!(Error::watch_error("msg").is_recoverable());
        assert!(!Error::internal("msg").is_recoverable());
    }

    #[test]
    fn test_error_with_source_context() {
        let err = Error::parse_error_with_source(
            "test.ncl",
            "unexpected token",
            "let x = @invalid".to_string(),
            8,
            8,
        );
        assert!(err.is_recoverable());
        assert_eq!(err.message(), "unexpected token");
    }

    #[test]
    fn test_error_message() {
        assert_eq!(Error::parse_error("f", "msg").message(), "msg");
        assert_eq!(Error::evaluation_error("f", "eval").message(), "eval");
        assert_eq!(Error::serialization_error("ser").message(), "ser");
        assert_eq!(Error::invalid_input("inp").message(), "inp");
        assert_eq!(Error::watch_error("watch").message(), "watch");
        assert_eq!(Error::internal("int").message(), "int");
    }
}
