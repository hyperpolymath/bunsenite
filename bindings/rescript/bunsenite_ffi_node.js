// Bunsenite ReScript FFI Glue (Node.js version)
// Uses node-ffi-napi for native FFI
//
// Install: npm install ffi-napi ref-napi

const ffi = require("ffi-napi");
const ref = require("ref-napi");
const path = require("path");
const fs = require("fs");

// Type definitions
const string = ref.types.CString;
const int = ref.types.int;
const uint8 = ref.types.uint8;
const voidType = ref.types.void;
const stringPtr = ref.refType(string);

// Detect library path
function getLibraryPath() {
  const platform = process.platform;
  const libName = platform === "win32" ? "bunsenite.dll"
    : platform === "darwin" ? "libbunsenite.dylib"
    : "libbunsenite.so";

  const paths = [
    path.join(__dirname, "../../zig/zig-out/lib", libName),
    path.join(__dirname, "../../target/release", libName),
    path.join(__dirname, libName),
  ];

  for (const libPath of paths) {
    if (fs.existsSync(libPath)) {
      return libPath;
    }
  }

  throw new Error(`Could not find ${libName}. Build with: cargo build --release && cd zig && zig build`);
}

// Load the native library
let lib = null;

function getLib() {
  if (!lib) {
    const libPath = getLibraryPath();
    lib = ffi.Library(libPath, {
      parse_nickel: [stringPtr, [string, string]],
      validate_nickel: [int, [string, string]],
      free_string: [voidType, [stringPtr]],
      version: [string, []],
      rsr_tier: [string, []],
      tpcf_perimeter: [uint8, []],
    });
  }
  return lib;
}

// Parse Nickel configuration
function parse_nickel(source, name) {
  const library = getLib();
  const resultPtr = library.parse_nickel(source, name);

  if (resultPtr.isNull()) {
    return null;
  }

  try {
    return resultPtr.deref();
  } finally {
    library.free_string(resultPtr);
  }
}

// Validate Nickel configuration
function validate_nickel(source, name) {
  const library = getLib();
  return library.validate_nickel(source, name);
}

// Get version
function version() {
  const library = getLib();
  return library.version();
}

// Get RSR tier
function rsr_tier() {
  const library = getLib();
  return library.rsr_tier();
}

// Get TPCF perimeter
function tpcf_perimeter() {
  const library = getLib();
  return library.tpcf_perimeter();
}

module.exports = {
  parse_nickel,
  validate_nickel,
  version,
  rsr_tier,
  tpcf_perimeter,
};
