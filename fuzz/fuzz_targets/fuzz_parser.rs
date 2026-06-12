// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//! Fuzz target for bunsenite Nickel parser

#![no_main]

use libfuzzer_sys::fuzz_target;
use bunsenite::NickelLoader;

fuzz_target!(|data: &[u8]| {
    // Convert bytes to string for parsing
    if let Ok(input) = std::str::from_utf8(data) {
        let loader = NickelLoader::new();

        // Fuzz the main parsing function
        // This exercises nickel-lang-core's parser with arbitrary input
        let _ = loader.parse_string(input, "fuzz.ncl");

        // Also fuzz validation (parsing without evaluation)
        let _ = loader.validate(input, "fuzz.ncl");
    }
});
