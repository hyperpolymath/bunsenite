# Bunsenite Packaging Guide

This document describes how to package and distribute Bunsenite for various package managers.

## Package Managers

### Linux

| Manager | Distro | Config Location |
|---------|--------|-----------------|
| pacman | Arch Linux | `packaging/arch/PKGBUILD` |
| apt | Debian/Ubuntu | `packaging/debian/` |
| dnf | Fedora/RHEL | `packaging/rpm/bunsenite.spec` |
| zypper | openSUSE | `packaging/rpm/bunsenite.spec` |
| flatpak | Universal | `packaging/flatpak/` |

### macOS

| Manager | Config Location |
|---------|-----------------|
| Homebrew | `packaging/homebrew/bunsenite.rb` |
| MacPorts | `packaging/macports/Portfile` |

### Windows

| Manager | Config Location |
|---------|-----------------|
| Scoop | `packaging/scoop/bunsenite.json` |
| Chocolatey | `packaging/chocolatey/bunsenite.nuspec` |
| winget | `packaging/winget/bunsenite.yaml` |

### Language Package Managers

| Manager | Language | Location |
|---------|----------|----------|
| cargo | Rust | `Cargo.toml` (publish to crates.io) |
| npm | Node.js | `bindings/rescript/package.json` |
| deno.land/x | Deno | `bindings/deno/` (publish to deno.land) |

## Build Requirements

All packaging scripts assume:

1. **Rust 1.70+** - For the core library
2. **Zig 0.11+** - For the FFI layer
3. **Git** - For source fetching

## Building Release Artifacts

```bash
# Build with all features
cargo build --release --features full

# Build Zig FFI layer
cd zig && zig build -Doptimize=ReleaseFast

# Run tests
cargo test --release
```

## Release Artifacts

Each release should include:

### Linux (x86_64, aarch64)
- `bunsenite-VERSION-x86_64-unknown-linux-gnu.tar.gz`
- `bunsenite-VERSION-aarch64-unknown-linux-gnu.tar.gz`

### macOS (x86_64, aarch64)
- `bunsenite-VERSION-x86_64-apple-darwin.tar.gz`
- `bunsenite-VERSION-aarch64-apple-darwin.tar.gz`

### Windows (x86_64)
- `bunsenite-VERSION-x86_64-pc-windows-msvc.zip`

### Source
- `bunsenite-VERSION.tar.gz`

## Publishing Checklist

### crates.io (Rust)
```bash
cargo publish --dry-run
cargo publish
```

### npm (Node.js bindings)
```bash
cd bindings/rescript
npm publish --access public
```

### Homebrew
1. Fork homebrew-core
2. Update `bunsenite.rb` with new version and sha256
3. Submit PR

### Arch Linux (AUR)
1. Update PKGBUILD with new version
2. Generate .SRCINFO: `makepkg --printsrcinfo > .SRCINFO`
3. Push to AUR

### Flatpak (Flathub)
1. Fork flathub/com.campaignforcoolercoding.bunsenite
2. Update manifest with new version
3. Submit PR

## CI/CD Integration

The `.github/workflows/release.yml` workflow automates:
- Building release binaries for all platforms
- Creating GitHub releases with artifacts
- Publishing to crates.io

## RSR Compliance Notes

All packages must include:
- LICENSE-PMPL-1.0
- LICENSE-PALIMPSEST (if applicable)
- README.md with RSR tier disclosure

Package descriptions should include:
```
RSR Compliance: Bronze Tier | TPCF Perimeter: 3
```
