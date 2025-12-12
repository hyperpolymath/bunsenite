# Publishing Bunsenite

This guide walks through publishing bunsenite to all package managers.

## Prerequisites

You'll need accounts and tokens for:
- **crates.io** - Rust package registry
- **npm** - Node.js package registry
- **GitHub** - For releases and Homebrew tap

## Step 1: Configure GitHub Secrets

Go to your repo → Settings → Secrets and variables → Actions → New repository secret

| Secret Name | How to Get It |
|-------------|---------------|
| `CARGO_REGISTRY_TOKEN` | https://crates.io/settings/tokens → New Token |
| `NPM_TOKEN` | https://www.npmjs.com/settings/tokens → Generate New Token (Automation) |

## Step 2: Create and Push a Tag

```bash
# Create the v1.0.0 tag
git tag -a v1.0.0 -m "Release v1.0.0"

# Push the tag (this triggers the release workflow)
git push origin v1.0.0
```

This automatically:
- Builds binaries for Linux, macOS, Windows
- Creates a GitHub Release with all artifacts
- Publishes to crates.io
- Publishes to npm

## Step 3: Homebrew (Manual)

Option A: **Create your own tap** (recommended for new packages):

```bash
# Create a new repo: hyperpolymath/homebrew-tap
# Then add the formula

mkdir -p homebrew-tap/Formula
cp packaging/homebrew/bunsenite.rb homebrew-tap/Formula/

# Update the sha256 from the GitHub release
# Then users install with:
# brew tap hyperpolymath/tap
# brew install bunsenite
```

Option B: **Submit to homebrew-core** (after package is established):

```bash
# Fork homebrew/homebrew-core
# Add Formula/bunsenite.rb
# Submit PR
```

## Step 4: Arch Linux (AUR)

```bash
# Clone your AUR package (first time: create it)
git clone ssh://aur@aur.archlinux.org/bunsenite.git aur-bunsenite
cd aur-bunsenite

# Copy PKGBUILD
cp ../packaging/arch/PKGBUILD .

# Update checksums
updpkgsums

# Generate .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# Commit and push
git add PKGBUILD .SRCINFO
git commit -m "Update to v1.0.0"
git push
```

## Step 5: Other Package Managers

### Flatpak (Flathub)
1. Fork https://github.com/flathub/flathub
2. Create `com.campaignforcoolercoding.bunsenite/` directory
3. Copy `packaging/flatpak/com.campaignforcoolercoding.bunsenite.yml`
4. Submit PR

### Scoop (Windows)
1. Fork https://github.com/ScoopInstaller/Main (or create own bucket)
2. Add `bucket/bunsenite.json`
3. Submit PR

### Chocolatey (Windows)
```bash
cd packaging/chocolatey
# Update bunsenite.nuspec with correct URLs
choco pack
choco push bunsenite.1.0.0.nupkg --source https://push.chocolatey.org/
```

### winget (Windows)
1. Fork https://github.com/microsoft/winget-pkgs
2. Create `manifests/c/CampaignForCoolerCoding/Bunsenite/1.0.0/`
3. Copy and split manifest files
4. Submit PR

## Quick Start Commands

```bash
# Step 1: Add secrets to GitHub (do this in browser)

# Step 2: Tag and release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Step 3: Wait for CI, then verify
# - Check GitHub Actions for build status
# - Check https://crates.io/crates/bunsenite
# - Check https://www.npmjs.com/package/bunsenite
```

## Verification

After publishing, verify each registry:

```bash
# Cargo
cargo install bunsenite

# npm
npm info bunsenite

# GitHub Release
gh release view v1.0.0
```
