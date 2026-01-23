// SPDX-License-Identifier: PMPL-1.0-or-later
// Bunsenite ReScript Bindings Example

open Bunsenite

// Example 1: Simple parsing
let example1 = () => {
  Console.log("\n📝 Example 1: Simple Configuration Parsing\n")

  let config = parseNickel(
    "{
      app_name = \"my-application\",
      version = \"1.0.0\",
      port = 8080
    }",
    "app-config.ncl",
  )

  switch config {
  | Ok(json) => {
      Console.log("✓ Configuration parsed successfully!")
      Console.log(Js.Json.stringify(json))

      // Extract specific values
      switch getConfigValue(json, list{"app_name"}) {
      | Some(name) => Console.log(`App name: ${Js.Json.stringify(name)}`)
      | None => Console.log("App name not found")
      }

      switch getConfigValue(json, list{"port"}) {
      | Some(port) => Console.log(`Port: ${Js.Json.stringify(port)}`)
      | None => Console.log("Port not found")
      }
    }
  | Error(err) => Console.error(`✗ Parse error: ${errorToString(err)}`)
  }
}

// Example 2: Nested configuration
let example2 = () => {
  Console.log("\n📝 Example 2: Nested Configuration\n")

  let config = parseNickel(
    "{
      server = {
        host = \"0.0.0.0\",
        port = 3000,
        tls = {
          enabled = true,
          cert_path = \"/path/to/cert.pem\"
        }
      },
      database = {
        host = \"localhost\",
        port = 5432,
        name = \"myapp\"
      }
    }",
    "server-config.ncl",
  )

  switch config {
  | Ok(json) => {
      Console.log("✓ Nested configuration parsed!")

      // Extract deeply nested values
      switch getConfigValue(json, list{"server", "tls", "enabled"}) {
      | Some(tls) => Console.log(`TLS enabled: ${Js.Json.stringify(tls)}`)
      | None => Console.log("TLS setting not found")
      }

      switch getConfigValue(json, list{"database", "name"}) {
      | Some(dbName) => Console.log(`Database name: ${Js.Json.stringify(dbName)}`)
      | None => Console.log("Database name not found")
      }
    }
  | Error(err) => Console.error(`✗ Parse error: ${errorToString(err)}`)
  }
}

// Example 3: Validation before parsing
let example3 = () => {
  Console.log("\n📝 Example 3: Configuration Validation\n")

  let configSource = "{
    api_key = \"secret-key-123\",
    timeout = 30,
    retries = 3
  }"

  // First validate
  let validation = validateNickel(configSource, "api-config.ncl")

  switch validation {
  | Ok() => {
      Console.log("✓ Configuration is valid, proceeding to parse...")

      // Now parse
      switch parseNickel(configSource, "api-config.ncl") {
      | Ok(json) => {
          Console.log("✓ Configuration parsed successfully!")
          Console.log(Js.Json.stringify(json))
        }
      | Error(err) => Console.error(`✗ Parse error: ${errorToString(err)}`)
      }
    }
  | Error(err) => Console.error(`✗ Validation failed: ${errorToString(err)}`)
  }
}

// Example 4: Error handling
let example4 = () => {
  Console.log("\n📝 Example 4: Error Handling\n")

  let invalidConfig = "{
    this is not = valid nickel syntax
  }"

  let result = parseNickel(invalidConfig, "bad-config.ncl")

  switch result {
  | Ok(json) => {
      Console.log("Parsed (unexpected):")
      Console.log(Js.Json.stringify(json))
    }
  | Error(ParseError(msg)) => {
      Console.log(`✓ Caught parse error: ${msg}`)
      Console.log("This is expected - the syntax was invalid")
    }
  | Error(ValidationError(msg)) => Console.log(`Validation error: ${msg}`)
  | Error(InvalidInput(msg)) => Console.log(`Invalid input: ${msg}`)
  }
}

// Example 5: Array configuration
let example5 = () => {
  Console.log("\n📝 Example 5: Array Configuration\n")

  let config = parseNickel(
    "{
      users = [
        \"alice\",
        \"bob\",
        \"charlie\"
      ],
      ports = [8080, 8081, 8082],
      features = {
        enabled = [\"auth\", \"logging\", \"metrics\"]
      }
    }",
    "array-config.ncl",
  )

  switch config {
  | Ok(json) => {
      Console.log("✓ Array configuration parsed!")

      switch getConfigValue(json, list{"users"}) {
      | Some(users) => Console.log(`Users: ${Js.Json.stringify(users)}`)
      | None => Console.log("Users not found")
      }

      switch getConfigValue(json, list{"features", "enabled"}) {
      | Some(features) => Console.log(`Enabled features: ${Js.Json.stringify(features)}`)
      | None => Console.log("Features not found")
      }
    }
  | Error(err) => Console.error(`✗ Parse error: ${errorToString(err)}`)
  }
}

// Example 6: Library information
let example6 = () => {
  Console.log("\n📝 Example 6: Library Information\n")

  Console.log(`Bunsenite version: ${getVersion()}`)
  Console.log(`RSR compliance tier: ${getRSRTier()}`)
  Console.log(`TPCF perimeter: ${getTPCFPerimeter()->Int.toString}`)
}

// Example 7: Type-safe configuration with pattern matching
let example7 = () => {
  Console.log("\n📝 Example 7: Type-Safe Configuration Access\n")

  let config = parseNickel(
    "{
      mode = \"production\",
      debug = false,
      log_level = \"info\"
    }",
    "env-config.ncl",
  )

  // Type-safe access with exhaustive pattern matching
  let mode = switch config {
  | Ok(json) =>
    switch getConfigValue(json, list{"mode"}) {
    | Some(value) =>
      switch Js.Json.classify(value) {
      | JSONString(str) => Some(str)
      | _ => None
      }
    | None => None
    }
  | Error(_) => None
  }

  switch mode {
  | Some("production") => Console.log("✓ Running in production mode")
  | Some("development") => Console.log("Running in development mode")
  | Some(other) => Console.log(`Running in ${other} mode`)
  | None => Console.log("Mode not specified")
  }
}

// Run all examples
let runExamples = () => {
  Console.log("🎯 Bunsenite ReScript Bindings Examples")
  Console.log("=" |> Js.String.repeat(50))

  example1()
  example2()
  example3()
  example4()
  example5()
  example6()
  example7()

  Console.log("\n✅ All examples completed!\n")
}

// Export for use in other files
let examples = [
  ("simple", example1),
  ("nested", example2),
  ("validation", example3),
  ("error-handling", example4),
  ("arrays", example5),
  ("library-info", example6),
  ("type-safe", example7),
]

// Run if executed directly
runExamples()
