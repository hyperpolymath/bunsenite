//! Schema validation for Nickel configurations
//!
//! This module provides JSON Schema validation for parsed Nickel configurations.
//! It allows validating that the output of a Nickel config matches an expected schema.

use crate::error::{Error, Result};
use jsonschema::{JSONSchema, ValidationError};
use serde_json::Value;
use std::path::Path;

/// Schema validator for Nickel configurations
#[derive(Debug)]
pub struct SchemaValidator {
    schema: JSONSchema,
    schema_source: String,
}

impl SchemaValidator {
    /// Create a new schema validator from a JSON schema value
    pub fn new(schema: Value) -> Result<Self> {
        let compiled = JSONSchema::compile(&schema)
            .map_err(|e| Error::invalid_input(format!("Invalid JSON schema: {}", e)))?;

        Ok(Self {
            schema: compiled,
            schema_source: serde_json::to_string_pretty(&schema)
                .unwrap_or_else(|_| "<schema>".to_string()),
        })
    }

    /// Create a new schema validator from a JSON schema string
    pub fn from_str(schema_str: &str) -> Result<Self> {
        let schema: Value = serde_json::from_str(schema_str)
            .map_err(|e| Error::invalid_input(format!("Invalid JSON: {}", e)))?;
        Self::new(schema)
    }

    /// Create a new schema validator from a file path
    pub fn from_file(path: impl AsRef<Path>) -> Result<Self> {
        let content = std::fs::read_to_string(path.as_ref())?;
        Self::from_str(&content)
    }

    /// Validate a JSON value against the schema
    pub fn validate(&self, value: &Value) -> Result<()> {
        let result = self.schema.validate(value);

        if let Err(errors) = result {
            let error_messages: Vec<String> = errors
                .map(|e| format!("  - {}: {}", e.instance_path, e))
                .collect();

            return Err(Error::invalid_input(format!(
                "Schema validation failed:\n{}",
                error_messages.join("\n")
            )));
        }

        Ok(())
    }

    /// Check if a value is valid without returning detailed errors
    pub fn is_valid(&self, value: &Value) -> bool {
        self.schema.is_valid(value)
    }

    /// Get validation errors as a list of strings
    pub fn get_errors(&self, value: &Value) -> Vec<String> {
        match self.schema.validate(value) {
            Ok(_) => vec![],
            Err(errors) => errors
                .map(|e| format!("{}: {}", e.instance_path, e))
                .collect(),
        }
    }
}

/// Validate a Nickel configuration against a JSON schema
///
/// # Arguments
///
/// * `config` - The parsed Nickel configuration as a JSON value
/// * `schema` - The JSON schema to validate against
///
/// # Returns
///
/// Returns `Ok(())` if validation passes, or an error with details on failure.
pub fn validate_config(config: &Value, schema: &Value) -> Result<()> {
    let validator = SchemaValidator::new(schema.clone())?;
    validator.validate(config)
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn test_valid_schema() {
        let schema = json!({
            "type": "object",
            "properties": {
                "name": { "type": "string" },
                "version": { "type": "string" }
            },
            "required": ["name"]
        });

        let validator = SchemaValidator::new(schema).unwrap();

        let valid_config = json!({
            "name": "test",
            "version": "1.0.0"
        });

        assert!(validator.validate(&valid_config).is_ok());
        assert!(validator.is_valid(&valid_config));
    }

    #[test]
    fn test_invalid_config() {
        let schema = json!({
            "type": "object",
            "properties": {
                "name": { "type": "string" }
            },
            "required": ["name"]
        });

        let validator = SchemaValidator::new(schema).unwrap();

        let invalid_config = json!({
            "version": "1.0.0"
        });

        assert!(validator.validate(&invalid_config).is_err());
        assert!(!validator.is_valid(&invalid_config));
    }

    #[test]
    fn test_type_validation() {
        let schema = json!({
            "type": "object",
            "properties": {
                "port": { "type": "integer", "minimum": 1, "maximum": 65535 }
            }
        });

        let validator = SchemaValidator::new(schema).unwrap();

        let valid = json!({ "port": 8080 });
        let invalid_type = json!({ "port": "8080" });
        let invalid_range = json!({ "port": 70000 });

        assert!(validator.is_valid(&valid));
        assert!(!validator.is_valid(&invalid_type));
        assert!(!validator.is_valid(&invalid_range));
    }

    #[test]
    fn test_get_errors() {
        let schema = json!({
            "type": "object",
            "properties": {
                "name": { "type": "string" },
                "port": { "type": "integer" }
            },
            "required": ["name", "port"]
        });

        let validator = SchemaValidator::new(schema).unwrap();

        let invalid = json!({ "name": 123 });
        let errors = validator.get_errors(&invalid);

        assert!(!errors.is_empty());
    }

    #[test]
    fn test_from_str() {
        let schema_str = r#"{
            "type": "object",
            "properties": {
                "enabled": { "type": "boolean" }
            }
        }"#;

        let validator = SchemaValidator::from_str(schema_str).unwrap();
        let valid = json!({ "enabled": true });

        assert!(validator.is_valid(&valid));
    }

    #[test]
    fn test_validate_config_function() {
        let config = json!({ "name": "test" });
        let schema = json!({
            "type": "object",
            "properties": {
                "name": { "type": "string" }
            }
        });

        assert!(validate_config(&config, &schema).is_ok());
    }
}
