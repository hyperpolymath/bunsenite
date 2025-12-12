# RPM spec file for bunsenite
# Compatible with Fedora (dnf) and openSUSE (zypper)

Name:           bunsenite
Version:        1.0.0
Release:        1%{?dist}
Summary:        Nickel configuration file parser with multi-language FFI bindings

License:        MIT OR Palimpsest-0.8
URL:            https://github.com/hyperpolymath/bunsenite
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.70
BuildRequires:  cargo
BuildRequires:  zig
BuildRequires:  gcc

Requires:       glibc

%description
Bunsenite is a Nickel configuration file parser with multi-language
FFI bindings. It provides a Rust core library with a stable C ABI
layer (via Zig) that enables bindings for Deno (JavaScript/TypeScript),
Rescript, and WebAssembly.

Features:
- Type Safety: Compile-time guarantees via Rust's type system
- Memory Safety: Rust ownership model, zero unsafe blocks
- Offline-First: Works completely air-gapped
- Multi-Language: FFI bindings for Deno, Rescript, and WASM

RSR Compliance: Bronze Tier | TPCF Perimeter: 3

%package devel
Summary:        Development files for bunsenite
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description devel
Development files for bunsenite including headers and static libraries.

%prep
%autosetup

%build
cargo build --release --features full
cd zig && zig build -Doptimize=ReleaseFast

%check
cargo test --release

%install
# Binary
install -D -m 755 target/release/bunsenite %{buildroot}%{_bindir}/bunsenite

# Shared library
install -D -m 755 zig/zig-out/lib/libbunsenite.so %{buildroot}%{_libdir}/libbunsenite.so.1.0.0
ln -s libbunsenite.so.1.0.0 %{buildroot}%{_libdir}/libbunsenite.so.1
ln -s libbunsenite.so.1 %{buildroot}%{_libdir}/libbunsenite.so

# Documentation
install -D -m 644 README.md %{buildroot}%{_docdir}/%{name}/README.md

%files
%license LICENSE-MIT LICENSE-PALIMPSEST
%doc README.md
%{_bindir}/bunsenite
%{_libdir}/libbunsenite.so.1*

%files devel
%{_libdir}/libbunsenite.so

%changelog
* Thu Jan 01 2025 Campaign for Cooler Coding <packages@example.com> - 1.0.0-1
- Initial release
