# Homebrew formula for bunsenite
class Bunsenite < Formula
  desc "Nickel configuration file parser with multi-language FFI bindings"
  homepage "https://github.com/hyperpolymath/bunsenite"
  url "https://github.com/hyperpolymath/bunsenite/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "TODO"
  license any_of: ["PMPL-1.0", "Palimpsest-0.8"]
  head "https://github.com/hyperpolymath/bunsenite.git", branch: "main"

  depends_on "rust" => :build
  depends_on "zig" => :build

  def install
    # Build Rust binary with all features
    system "cargo", "build", "--release", "--features=full"

    # Build Zig FFI layer
    cd "zig" do
      system "zig", "build", "-Doptimize=ReleaseFast"
    end

    # Install binary
    bin.install "target/release/bunsenite"

    # Install shared library
    lib.install "zig/zig-out/lib/libbunsenite.dylib"

    # Create symlink for Linux compatibility
    lib.install_symlink "libbunsenite.dylib" => "libbunsenite.so" if OS.linux?
  end

  test do
    # Test version output
    assert_match version.to_s, shell_output("#{bin}/bunsenite --version")

    # Test parsing a simple Nickel config
    (testpath/"test.ncl").write <<~EOS
      {
        name = "test",
        version = "1.0.0"
      }
    EOS

    output = shell_output("#{bin}/bunsenite parse #{testpath}/test.ncl")
    assert_match "name", output
    assert_match "test", output
  end
end
