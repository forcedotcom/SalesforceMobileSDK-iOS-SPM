---
skill: sqlcipher-update
description: Update SQLCipher dependency in Salesforce Mobile SDK for iOS SPM distribution
globs:
  - "Package.swift"
tags:
  - dependency-update
  - sqlcipher
  - encryption
  - smartstore
  - spm
---

# Update SQLCipher Skill (iOS-SPM)

This skill automates the process of updating the SQLCipher library version in the SalesforceMobileSDK-iOS-SPM Swift Package Manager distribution repository.

## When to Use
Use this skill when you need to:
- Update SQLCipher to a newer version for security patches or new features
- Align the SPM distribution with SQLCipher updates in the main iOS repo
- Ensure SPM consumers get the latest SQLCipher version

## Background
SQLCipher is an open-source extension to SQLite that provides transparent 256-bit AES encryption of database files. The SDK uses it in the SmartStore library for secure local data storage.

The iOS-SPM repository is a **binary distribution repository** that uses Swift Package Manager. It references SQLCipher as an external package dependency.

## Parameters
- `NEW_VERSION`: The new SQLCipher version (e.g., "4.15.0", "4.16.0")
- `OLD_VERSION`: The current SQLCipher version (check Package.swift)

## Prerequisite
- SQLCipher version is available at https://github.com/sqlcipher/SQLCipher.swift.git
- The main iOS repo (SalesforceMobileSDK-iOS) has been updated to the same version
- The iOS-Specs CocoaPods repo has been updated with the new SQLCipher podspec

## Process

### 1. Research the New Version

Before starting, check the SQLCipher release notes:
- Visit: https://github.com/sqlcipher/sqlcipher/releases
- Review changes, breaking changes, and new features
- Check for API changes that might affect the SDK

**Key things to look for:**
- Provider version changes (OpenSSL/LibTomCrypt versions)
- Security fixes or enhancements
- Changes to encryption algorithms or key derivation

### 2. Update Package.swift

Update the SQLCipher dependency version in Package.swift:

**Before:**
```swift
dependencies: [
    .package(url: "https://github.com/sqlcipher/SQLCipher.swift.git", exact: "OLD_VERSION"),
    .package(url: "https://github.com/forcedotcom/fmdb.git", exact: "2.7.12-sqlcipher")
],
```

**After:**
```swift
dependencies: [
    .package(url: "https://github.com/sqlcipher/SQLCipher.swift.git", exact: "NEW_VERSION"),
    .package(url: "https://github.com/forcedotcom/fmdb.git", exact: "2.7.12-sqlcipher")
],
```

**Note:** The SDK uses exact version constraints for stability. Only update the SQLCipher version, not FMDB unless explicitly required.

### 3. Verify Package Resolution

Test that SPM can resolve the updated package:

```bash
swift package resolve
```

This validates that:
- The new SQLCipher version exists and is accessible
- All dependencies can be resolved together
- No version conflicts exist

### 4. Test Locally

Create a test Xcode project to verify the package works:

```bash
# Method 1: Add as local package in Xcode
# File → Add Package Dependencies → Add Local...
# Select the iOS-SPM directory

# Method 2: Create a test Package.swift
mkdir -p /tmp/test-spm
cd /tmp/test-spm
cat > Package.swift <<'EOF'
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TestSPM",
    platforms: [.iOS(.v18)],
    dependencies: [
        .package(path: "/path/to/SalesforceMobileSDK-iOS-SPM")
    ],
    targets: [
        .target(
            name: "TestSPM",
            dependencies: [
                .product(name: "SmartStore", package: "SalesforceMobileSDK-iOS-SPM")
            ]
        )
    ]
)
EOF
swift package resolve
```

### 5. Create Branch and Commit

```bash
# Create feature branch
git checkout -b sqlcipher-4.x.x

# Stage changes
git add Package.swift .claude/skills/update-sqlcipher/skill.md

# Commit with descriptive message
git commit -m "Update SQLCipher to 4.x.x"

# Push to origin (your fork)
git push -u origin sqlcipher-4.x.x
```

### 6. Create Pull Request

When creating the PR:
- **Title:** "Update SQLCipher to {NEW_VERSION}"
- **Description:** Include:
  - SQLCipher version being updated to
  - Link to SQLCipher release notes
  - Reference to corresponding iOS repo PR (if applicable)
  - Note that this is for SPM distribution
  - Any breaking changes or migration notes

**Example PR Description:**
```markdown
## Summary
Updates SQLCipher dependency from 4.15.0 to 4.16.0 in the SPM distribution.

## Details
- Updated Package.swift to reference SQLCipher 4.16.0
- Verified package resolution with `swift package resolve`
- Tested local package integration

## References
- SQLCipher Release: https://github.com/sqlcipher/sqlcipher/releases/tag/v4.16.0
- iOS Repo PR: https://github.com/forcedotcom/SalesforceMobileSDK-iOS/pull/XXXX
- iOS-Specs PR: https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs/pull/XXXX
- iOS-Hybrid PR: https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Hybrid/pull/XXXX
- Android PR: https://github.com/forcedotcom/SalesforceMobileSDK-Android/pull/XXXX

## Testing
- [x] `swift package resolve` succeeds
- [x] Local package integration tested in Xcode
```

## File Checklist

- [ ] `Package.swift` - Update SQLCipher dependency version
- [ ] `.claude/skills/update-sqlcipher/skill.md` - Create/update this skill (if first time)
- [ ] Verify `swift package resolve` succeeds
- [ ] Test local package integration

## Key Files Reference

**Configuration:**
- `Package.swift` - Swift Package Manager manifest with dependencies

**Build Archives:**
- `archives/` - Pre-built XCFrameworks (not affected by SQLCipher version)

**Note:** The actual SQLCipher library is pulled by SPM at build time. The XCFrameworks in archives/ are pre-built SDK libraries that depend on SQLCipher but don't include it.

## Important Notes

- This repo is a **distribution repository**. It does not contain SDK source code.
- The XCFrameworks in `archives/` are built from the main iOS repo and include compiled code that uses SQLCipher, but SQLCipher itself is resolved by SPM.
- Always coordinate SQLCipher updates across all SDK repositories:
  1. SalesforceMobileSDK-iOS (main source)
  2. SalesforceMobileSDK-iOS-Specs (CocoaPods)
  3. SalesforceMobileSDK-iOS-SPM (Swift Package Manager) ← This repo
  4. SalesforceMobileSDK-iOS-Hybrid (if applicable)
  5. SalesforceMobileSDK-Android (for consistency)
- Do not update XCFrameworks as part of a SQLCipher update — those are rebuilt during SDK releases using `build_xcframeworks.sh`

## Resources

- SQLCipher: https://www.zetetic.net/sqlcipher/
- SQLCipher iOS: https://github.com/sqlcipher/sqlcipher
- SQLCipher Swift Package: https://github.com/sqlcipher/SQLCipher.swift
- SQLCipher Releases: https://github.com/sqlcipher/sqlcipher/releases
- Swift Package Manager: https://swift.org/package-manager/
- SmartStore docs: https://forcedotcom.github.io/SalesforceMobileSDK-iOS/Documentation/SmartStore/html/index.html
