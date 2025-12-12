// TypeScript type definitions for bunsenite
// These types are for the Node.js/Bun FFI bindings

/**
 * Parse a Nickel configuration string and return the result as JSON
 * @param source - The Nickel source code to parse
 * @param name - The name of the file (for error messages)
 * @returns The parsed configuration as a JSON string, or null on error
 */
export function parse_nickel(source: string, name: string): string | null;

/**
 * Validate a Nickel configuration without evaluating it
 * @param source - The Nickel source code to validate
 * @param name - The name of the file (for error messages)
 * @returns 0 if valid, non-zero on error
 */
export function validate_nickel(source: string, name: string): number;

/**
 * Get the library version
 * @returns The version string (e.g., "1.0.0")
 */
export function version(): string;

/**
 * Get the RSR compliance tier
 * @returns The RSR tier (e.g., "bronze")
 */
export function rsr_tier(): string;

/**
 * Get the TPCF perimeter assignment
 * @returns The perimeter number (e.g., 3)
 */
export function tpcf_perimeter(): number;
