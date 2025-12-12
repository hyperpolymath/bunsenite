// Bunsenite Zig Build Configuration
//
// Build the Zig FFI layer as a shared library that wraps the Rust core.
//
// Prerequisites:
//   1. Build Rust library first: cargo build --release
//   2. Then build Zig layer: zig build -Doptimize=ReleaseFast
//
// Output:
//   zig-out/lib/libbunsenite.so (Linux)
//   zig-out/lib/libbunsenite.dylib (macOS)
//   zig-out/lib/bunsenite.dll (Windows)

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create shared library
    const lib = b.addSharedLibrary(.{
        .name = "bunsenite",
        .root_source_file = b.path("bunsenite.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link to Rust library
    // The Rust cdylib is built with: cargo build --release
    lib.addLibraryPath(.{ .cwd_relative = "../target/release" });
    lib.linkSystemLibrary("bunsenite");

    // Link libc for C runtime
    lib.linkLibC();

    // Install the library
    b.installArtifact(lib);

    // Create test step
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("bunsenite.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_unit_tests.addLibraryPath(.{ .cwd_relative = "../target/release" });
    lib_unit_tests.linkSystemLibrary("bunsenite");
    lib_unit_tests.linkLibC();

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
