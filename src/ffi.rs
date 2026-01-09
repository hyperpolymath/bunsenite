//! C FFI exports for Bunsenite
//!
//! This module provides C-compatible function exports that can be called
//! from Zig, which then re-exports them with stable ABI guarantees.
//!
//! # Safety
//!
//! These functions use `unsafe` for FFI boundary crossing. The Zig layer
//! provides additional safety guarantees and stable ABI.

use crate::NickelLoader;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

/// Parse a Nickel configuration string and return JSON
///
/// # Safety
///
/// - `source` must be a valid null-terminated C string
/// - `name` must be a valid null-terminated C string
/// - The returned pointer must be freed with `bunsenite_free_string`
#[no_mangle]
pub unsafe extern "C" fn bunsenite_parse(
    source: *const c_char,
    name: *const c_char,
) -> *mut c_char {
    if source.is_null() || name.is_null() {
        return std::ptr::null_mut();
    }

    let source_str = match CStr::from_ptr(source).to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let name_str = match CStr::from_ptr(name).to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let loader = NickelLoader::new();
    match loader.parse_string(source_str, name_str) {
        Ok(value) => {
            let json_string = match serde_json::to_string(&value) {
                Ok(s) => s,
                Err(_) => return std::ptr::null_mut(),
            };
            match CString::new(json_string) {
                Ok(cs) => cs.into_raw(),
                Err(_) => std::ptr::null_mut(),
            }
        }
        Err(_) => std::ptr::null_mut(),
    }
}

/// Validate a Nickel configuration without evaluating
///
/// # Safety
///
/// - `source` must be a valid null-terminated C string
/// - `name` must be a valid null-terminated C string
///
/// # Returns
///
/// - 0 on success (valid configuration)
/// - 1 on validation error
/// - -1 on invalid input (null pointers, invalid UTF-8)
#[no_mangle]
pub unsafe extern "C" fn bunsenite_validate(source: *const c_char, name: *const c_char) -> i32 {
    if source.is_null() || name.is_null() {
        return -1;
    }

    let source_str = match CStr::from_ptr(source).to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };

    let name_str = match CStr::from_ptr(name).to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };

    let loader = NickelLoader::new();
    match loader.validate(source_str, name_str) {
        Ok(()) => 0,
        Err(_) => 1,
    }
}

/// Free a string allocated by bunsenite_parse
///
/// # Safety
///
/// - `ptr` must be a pointer returned by `bunsenite_parse`
/// - `ptr` must not have been freed before
/// - `ptr` may be null (no-op)
#[no_mangle]
pub unsafe extern "C" fn bunsenite_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        drop(CString::from_raw(ptr));
    }
}

/// Get the library version
///
/// # Safety
///
/// The returned pointer is static and must NOT be freed.
#[no_mangle]
pub extern "C" fn bunsenite_version() -> *const c_char {
    static VERSION: &[u8] = concat!(env!("CARGO_PKG_VERSION"), "\0").as_bytes();
    VERSION.as_ptr() as *const c_char
}

/// Get the RSR compliance tier
///
/// # Safety
///
/// The returned pointer is static and must NOT be freed.
#[no_mangle]
pub extern "C" fn bunsenite_rsr_tier() -> *const c_char {
    static TIER: &[u8] = b"bronze\0";
    TIER.as_ptr() as *const c_char
}

/// Get the TPCF perimeter number
#[no_mangle]
pub extern "C" fn bunsenite_tpcf_perimeter() -> u8 {
    3 // Community Sandbox
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;

    #[test]
    fn test_ffi_parse_valid() {
        let source = CString::new("{ foo = 42 }").unwrap();
        let name = CString::new("test.ncl").unwrap();

        unsafe {
            let result = bunsenite_parse(source.as_ptr(), name.as_ptr());
            assert!(!result.is_null());

            let result_str = CStr::from_ptr(result).to_str().unwrap();
            assert!(result_str.contains("foo"));
            assert!(result_str.contains("42"));

            bunsenite_free_string(result);
        }
    }

    #[test]
    fn test_ffi_parse_invalid() {
        let source = CString::new("{ invalid = }").unwrap();
        let name = CString::new("bad.ncl").unwrap();

        unsafe {
            let result = bunsenite_parse(source.as_ptr(), name.as_ptr());
            assert!(result.is_null());
        }
    }

    #[test]
    fn test_ffi_validate_valid() {
        let source = CString::new("{ foo = 42 }").unwrap();
        let name = CString::new("test.ncl").unwrap();

        unsafe {
            let result = bunsenite_validate(source.as_ptr(), name.as_ptr());
            assert_eq!(result, 0);
        }
    }

    #[test]
    fn test_ffi_validate_invalid() {
        let source = CString::new("{ foo = }").unwrap();
        let name = CString::new("bad.ncl").unwrap();

        unsafe {
            let result = bunsenite_validate(source.as_ptr(), name.as_ptr());
            assert_eq!(result, 1);
        }
    }

    #[test]
    fn test_ffi_null_input() {
        unsafe {
            assert!(bunsenite_parse(std::ptr::null(), std::ptr::null()).is_null());
            assert_eq!(bunsenite_validate(std::ptr::null(), std::ptr::null()), -1);
        }
    }

    #[test]
    fn test_ffi_version() {
        let version = bunsenite_version();
        assert!(!version.is_null());
        unsafe {
            let version_str = CStr::from_ptr(version).to_str().unwrap();
            assert!(!version_str.is_empty());
        }
    }

    #[test]
    fn test_ffi_rsr_tier() {
        let tier = bunsenite_rsr_tier();
        assert!(!tier.is_null());
        unsafe {
            let tier_str = CStr::from_ptr(tier).to_str().unwrap();
            assert_eq!(tier_str, "bronze");
        }
    }

    #[test]
    fn test_ffi_tpcf_perimeter() {
        assert_eq!(bunsenite_tpcf_perimeter(), 3);
    }
}
