// Bunsenite ReScript FFI Glue
// This module provides the JavaScript bridge between ReScript and the Zig FFI layer
//
// The ReScript code (Bunsenite.res) imports this module via @module("./bunsenite_ffi")

import { dlopen, FFIType, suffix, ptr, toArrayBuffer, CString } from "bun:ffi";

// Detect library path based on platform
function getLibraryPath() {
  const libName = `libbunsenite.${suffix}`;
  const paths = [
    `../../zig/zig-out/lib/${libName}`,
    `../../target/release/${libName}`,
    `./${libName}`,
  ];

  for (const path of paths) {
    try {
      // Check if file exists
      Bun.file(path);
      return path;
    } catch {
      continue;
    }
  }

  throw new Error(`Could not find ${libName}. Build with: cargo build --release && cd zig && zig build`);
}

// Load the native library
let lib = null;

function getLib() {
  if (!lib) {
    const libPath = getLibraryPath();
    lib = dlopen(libPath, {
      parse_nickel: {
        args: [FFIType.cstring, FFIType.cstring],
        returns: FFIType.ptr,
      },
      validate_nickel: {
        args: [FFIType.cstring, FFIType.cstring],
        returns: FFIType.i32,
      },
      free_string: {
        args: [FFIType.ptr],
        returns: FFIType.void,
      },
      version: {
        args: [],
        returns: FFIType.ptr,
      },
      rsr_tier: {
        args: [],
        returns: FFIType.ptr,
      },
      tpcf_perimeter: {
        args: [],
        returns: FFIType.u8,
      },
    });
  }
  return lib;
}

// Convert C string pointer to JS string
function ptrToString(pointer) {
  if (!pointer) return null;
  return new CString(pointer);
}

// Parse Nickel configuration and return JSON string
export function parse_nickel(source, name) {
  const library = getLib();
  const resultPtr = library.symbols.parse_nickel(source, name);

  if (!resultPtr) {
    return null;
  }

  try {
    const result = ptrToString(resultPtr);
    return result;
  } finally {
    library.symbols.free_string(resultPtr);
  }
}

// Validate Nickel configuration
export function validate_nickel(source, name) {
  const library = getLib();
  return library.symbols.validate_nickel(source, name);
}

// Get library version
export function version() {
  const library = getLib();
  const ptr = library.symbols.version();
  return ptrToString(ptr);
}

// Get RSR tier
export function rsr_tier() {
  const library = getLib();
  const ptr = library.symbols.rsr_tier();
  return ptrToString(ptr);
}

// Get TPCF perimeter
export function tpcf_perimeter() {
  const library = getLib();
  return library.symbols.tpcf_perimeter();
}
