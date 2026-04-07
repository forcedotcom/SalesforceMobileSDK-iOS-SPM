# Update iOS Minimum Deployment Target

This skill updates the minimum iOS deployment target for the Salesforce Mobile SDK iOS-SPM (Swift Package Manager distribution) repository.

## When to Use
- After bumping the deployment target in SalesforceMobileSDK-iOS
- When creating a new SPM release with updated minimum iOS version
- Typically done once per major release cycle

## What This Skill Does

Updates the iOS deployment target in the Swift Package Manager manifest:

1. **Package.swift Manifest** - Updates platform minimum version
3. **Swift Tools Version** - Updates if needed for new deployment target

## Prerequisites

**IMPORTANT**: The deployment target must be updated in `SalesforceMobileSDK-iOS` FIRST. This skill updates the SPM distribution to match.

## Usage

When invoked, ask the user for:
- **Current minimum iOS version** (e.g., "17.0")
- **New minimum iOS version** (e.g., "18.0")
- **Whether Swift tools version needs updating** (usually not needed)

## Step-by-Step Process

### 1. Update Package.swift Platform Requirement

In `Package.swift`, update the platforms array for iOS and macCatalyst:

```swift
platforms: [
    .iOS(.vX),  // Update this line
    .watchOS(.v8),
    .visionOS(.v2),
    .macCatalyst(.v13)
],
```

**Example**: Change `.iOS(.v17)` to `.iOS(.v18)`

### 2. Update Swift Tools Version (If Needed)

Only update if the new deployment target requires a newer Swift version:

At the top of `Package.swift`:
```swift
// swift-tools-version: X.X
```

**Historical mappings**:
- iOS 16 requires Swift tools 5.7+
- iOS 17 requires Swift tools 5.9+
- iOS 18 requires Swift tools 6.0+

Check [Swift.org](https://swift.org) for current requirements.

### 3. Update Documentation
 Update `README.md` and `CLAUDE.md`

### 4. Test Package Compilation

```
xcodebuild -scheme SalesforceMobileSDK-Package -destination 'generic/platform=iOS Simulator'

xcodebuild -scheme SalesforceMobileSDK-Package -destination 'generic/platform=iOS'

```

## Important Notes

- **STOP and FLAG for human review**: Deployment target changes affect all SDK consumers
- **Breaking change**: Document in release notes and migration guide

## What NOT to Update

Unlike the iOS repo, iOS-SPM does NOT have:
- ❌ Podspec files (see iOS-Specs repo)
- ❌ .xcconfig files
- ❌ .pbxproj files
- ❌ install.sh script
- ❌ CI workflow files
- ❌ Source code with version checks

**Only update Package.swift and rebuild XCFrameworks.**

## Example Command Flow

```bash
# 1. Create a feature branch
cd SalesforceMobileSDK-iOS-SPM
git checkout -b bump-ios-18

# 2. Update Package.swift manually or let skill do it
# Change .iOS(.v17) to .iOS(.v18)

# 3. Build locally
# Build package scheme


```

## Historical References
- PR #5: iOS 17 bump (changed `.iOS(.v16)` to `.iOS(.v17)`)
- PR #3: Swift tools 5.7 bump (enabled iOS 16 support)

## Checklist

Before marking complete:
- [ ] Package.swift platform updated (`.iOS(.vX)`)
- [ ] Swift tools version updated if needed (`// swift-tools-version:`)
- [ ] Tested locally

