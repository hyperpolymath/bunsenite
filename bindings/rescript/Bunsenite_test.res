// SPDX-License-Identifier: MPL-2.0
// Bunsenite ReScript Bindings Test Suite

open Bunsenite

// Test helpers
let assertEqual = (actual, expected, testName) => {
  if actual == expected {
    Console.log(`✓ ${testName}`)
  } else {
    Console.error(`✗ ${testName}`)
    Console.error(`  Expected: ${expected->Js.Json.stringify}`)
    Console.error(`  Actual: ${actual->Js.Json.stringify}`)
  }
}

let assertOk = (result, testName) => {
  switch result {
  | Ok(_) => Console.log(`✓ ${testName}`)
  | Error(err) => {
      Console.error(`✗ ${testName}`)
      Console.error(`  Error: ${errorToString(err)}`)
    }
  }
}

let assertError = (result, testName) => {
  switch result {
  | Error(_) => Console.log(`✓ ${testName}`)
  | Ok(_) => Console.error(`✗ ${testName}: Expected error but got Ok`)
  }
}

// Test suite
let runTests = () => {
  Console.log("\n🧪 Bunsenite ReScript Bindings Test Suite\n")

  // Test 1: Parse simple Nickel configuration
  Console.log("Parse Tests:")
  let simpleConfig = parseNickel("{foo = 42}", "test.ncl")
  assertOk(simpleConfig, "Parse simple number configuration")

  // Test 2: Parse object configuration
  let objectConfig = parseNickel("{name = \"test\", value = 100}", "object.ncl")
  assertOk(objectConfig, "Parse object configuration")

  // Test 3: Parse nested configuration
  let nestedConfig = parseNickel("{server = {port = 8080, host = \"localhost\"}}", "nested.ncl")
  assertOk(nestedConfig, "Parse nested configuration")

  // Test 4: Parse array configuration
  let arrayConfig = parseNickel("{items = [1, 2, 3, 4, 5]}", "array.ncl")
  assertOk(arrayConfig, "Parse array configuration")

  // Test 5: Parse invalid syntax (should error)
  let invalidConfig = parseNickel("{foo = }", "invalid.ncl")
  assertError(invalidConfig, "Parse invalid syntax returns error")

  // Test 6: Parse empty configuration
  let emptyConfig = parseNickel("{}", "empty.ncl")
  assertOk(emptyConfig, "Parse empty configuration")

  // Validation Tests
  Console.log("\nValidation Tests:")

  let validConfig = validateNickel("{foo = 42}", "valid.ncl")
  assertOk(validConfig, "Validate correct configuration")

  let invalidValidation = validateNickel("{foo = }", "invalid-validate.ncl")
  assertError(invalidValidation, "Validate incorrect configuration returns error")

  // Test 7: Validate complex configuration
  let complexValid = validateNickel(
    "{
      app = {
        name = \"example\",
        version = \"1.0.0\",
        config = {
          debug = true,
          port = 3000
        }
      }
    }",
    "complex.ncl",
  )
  assertOk(complexValid, "Validate complex nested configuration")

  // Library Info Tests
  Console.log("\nLibrary Info Tests:")

  let version = getVersion()
  Console.log(`✓ Got version: ${version}`)

  let tier = getRSRTier()
  Console.log(`✓ Got RSR tier: ${tier}`)

  let perimeter = getTPCFPerimeter()
  Console.log(`✓ Got TPCF perimeter: ${perimeter->Int.toString}`)

  // Config Value Tests
  Console.log("\nConfig Value Extraction Tests:")

  switch objectConfig {
  | Ok(json) => {
      // Test extracting top-level value
      let nameValue = getConfigValue(json, list{"name"})
      switch nameValue {
      | Some(_) => Console.log("✓ Extract top-level value")
      | None => Console.error("✗ Failed to extract top-level value")
      }

      // Test extracting non-existent value
      let missingValue = getConfigValue(json, list{"missing"})
      switch missingValue {
      | None => Console.log("✓ Non-existent value returns None")
      | Some(_) => Console.error("✗ Non-existent value should return None")
      }
    }
  | Error(_) => Console.error("✗ Could not test config value extraction")
  }

  switch nestedConfig {
  | Ok(json) => {
      // Test extracting nested value
      let portValue = getConfigValue(json, list{"server", "port"})
      switch portValue {
      | Some(_) => Console.log("✓ Extract nested value")
      | None => Console.error("✗ Failed to extract nested value")
      }

      // Test extracting with invalid path
      let invalidPath = getConfigValue(json, list{"server", "nonexistent", "deep"})
      switch invalidPath {
      | None => Console.log("✓ Invalid nested path returns None")
      | Some(_) => Console.error("✗ Invalid path should return None")
      }
    }
  | Error(_) => Console.error("✗ Could not test nested value extraction")
  }

  // Error handling tests
  Console.log("\nError Handling Tests:")

  let parseErr = parseNickel("{invalid syntax here}", "error-test.ncl")
  switch parseErr {
  | Error(err) => {
      let errStr = errorToString(err)
      Console.log(`✓ Error converted to string: ${errStr}`)
    }
  | Ok(_) => Console.error("✗ Expected parse error")
  }

  // Result type tests
  Console.log("\nResult Type Tests:")

  let successResult: parseResult = Ok(Js.Json.null)
  switch successResult {
  | Ok(_) => Console.log("✓ parseResult Ok variant works")
  | Error(_) => Console.error("✗ parseResult Ok variant failed")
  }

  let errorResult: parseResult = Error(ParseError("test"))
  switch errorResult {
  | Error(_) => Console.log("✓ parseResult Error variant works")
  | Ok(_) => Console.error("✗ parseResult Error variant failed")
  }

  let validateSuccess: validateResult = Ok()
  switch validateSuccess {
  | Ok() => Console.log("✓ validateResult Ok variant works")
  | Error(_) => Console.error("✗ validateResult Ok variant failed")
  }

  Console.log("\n✅ Test suite complete\n")
}

// Run tests
runTests()
