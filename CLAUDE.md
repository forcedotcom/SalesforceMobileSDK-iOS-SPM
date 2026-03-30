# CLAUDE.md — Salesforce Mobile SDK for iOS - Swift Package Manager Distribution

---

## About This Project

The Salesforce Mobile SDK for iOS SPM repository is a **Swift Package Manager (SPM) distribution repository** containing pre-built XCFramework archives and a Package.swift manifest. It provides an alternative to CocoaPods for integrating the iOS SDK into Swift projects.

**Key constraint**: This is a **binary distribution repository**. It contains pre-built frameworks, not source code. The actual SDK source lives in `SalesforceMobileSDK-iOS`. Every release must contain valid, tested XCFrameworks that match the corresponding SDK release.

## Repository Role in SDK Architecture

This repository is the **Swift Package Manager distribution layer**:

```
SalesforceMobileSDK-iOS (source code)
  └── Libraries with source code
           │
           ▼
    build_xcframeworks.sh (in this repo)
    (clones iOS repo, builds frameworks)
           │
           ▼
SalesforceMobileSDK-iOS-SPM (this repo)
  ├── archives/ (pre-built XCFrameworks)
  ├── Package.swift (SPM manifest)
  └── Sources/ (SPM wrapper)
           │
           ▼
    Swift Package Manager
           │
           ▼
    iOS Apps (Xcode projects)
    (consume via SPM dependencies)
```

## Repository Structure

```
SalesforceMobileSDK-iOS-SPM/
├── Package.swift                     # Swift Package manifest
│
├── archives/                         # Pre-built XCFrameworks (zipped)
│   ├── SalesforceAnalytics.xcframework.zip
│   ├── SalesforceSDKCommon.xcframework.zip
│   ├── SalesforceSDKCore.xcframework.zip
│   ├── SmartStore.xcframework.zip
│   └── MobileSync.xcframework.zip
│
├── Sources/                          # SPM wrapper targets
│   └── SmartStoreWrapper/            # Wrapper to expose dependencies
│
├── build_xcframeworks.sh             # Script to build XCFrameworks
│
└── README.md
```

## How Swift Package Manager Uses This Repo

### In Xcode Projects

Apps add this package as a dependency:

**Via Xcode UI**:
1. File → Add Package Dependencies
2. Enter URL: `https://github.com/forcedotcom/SalesforceMobileSDK-iOS-SPM.git`
3. Select version/branch
4. Choose which libraries to link

**Via Package.swift** (for SPM packages):
```swift
dependencies: [
    .package(
        url: "https://github.com/forcedotcom/SalesforceMobileSDK-iOS-SPM.git",
        from: "13.2.0"
    )
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "MobileSync", package: "SalesforceMobileSDK-iOS-SPM"),
            .product(name: "SmartStore", package: "SalesforceMobileSDK-iOS-SPM")
        ]
    )
]
```

### Package.swift Manifest

The manifest defines available products and dependencies:

```swift
let package = Package(
    name: "SalesforceMobileSDK",
    platforms: [
        .iOS(.v17),
        .watchOS(.v8),
        .visionOS(.v2),
        .macCatalyst(.v13)
    ],
    products: [
        .library(name: "SalesforceAnalytics", targets: ["SalesforceAnalytics"]),
        .library(name: "SalesforceSDKCommon", targets: ["SalesforceSDKCommon"]),
        .library(name: "SalesforceSDKCore", targets: ["SalesforceSDKCore"]),
        .library(name: "SmartStore", targets: ["SmartStoreWrapper"]),
        .library(name: "MobileSync", targets: ["MobileSync"])
    ],
    dependencies: [
        .package(url: "https://github.com/sqlcipher/SQLCipher.swift.git", exact: "4.10.0"),
        .package(url: "https://github.com/forcedotcom/fmdb.git", exact: "2.7.12-sqlcipher")
    ],
    targets: [
        // Binary targets (pre-built XCFrameworks)
        .binaryTarget(
            name: "SalesforceAnalytics",
            path: "archives/SalesforceAnalytics.xcframework.zip"
        ),
        .binaryTarget(
            name: "SalesforceSDKCore",
            path: "archives/SalesforceSDKCore.xcframework.zip"
        ),
        // ... other binary targets ...

        // Wrapper target to expose dependencies
        .target(
            name: "SmartStoreWrapper",
            dependencies: [
                "SmartStoreBinary",
                .product(name: "SQLCipher", package: "SQLCipher.swift"),
                .product(name: "FMDB", package: "fmdb")
            ]
        )
    ]
)
```

**Key Points**:
- **Binary Targets**: Reference pre-built XCFrameworks (not source)
- **Dependencies**: External packages (SQLCipher, FMDB) pulled from GitHub
- **Wrapper Targets**: Expose binary targets with their dependencies

## XCFramework Archives

### What is an XCFramework?

An XCFramework is Apple's format for distributing binary frameworks that support multiple architectures and platforms:

```
SalesforceSDKCore.xcframework/
├── ios-arm64/                    # iOS devices (iPhone, iPad)
│   └── SalesforceSDKCore.framework
├── ios-arm64-simulator/          # iOS Simulator (Apple Silicon Macs)
│   └── SalesforceSDKCore.framework
└── ios-x86_64-simulator/         # iOS Simulator (Intel Macs)
    └── SalesforceSDKCore.framework
```

### Why Zipped?

XCFrameworks are zipped (`.xcframework.zip`) because:
- **Git efficiency**: Binary files compress well
- **Download optimization**: SPM downloads and extracts as needed
- **Size**: Reduces repository size

## Build Process

### The `build_xcframeworks.sh` Script

This script automates building XCFrameworks from source:

**Usage**:
```bash
./build_xcframeworks.sh -r <org> -b <branch>

# Examples:
./build_xcframeworks.sh -r forcedotcom -b dev
./build_xcframeworks.sh -r forcedotcom -b v13.2.0
```

**What it does**:
1. **Clones iOS Repo**: `git clone --branch <branch> https://github.com/<org>/SalesforceMobileSDK-iOS`
2. **Runs install.sh**: Pulls submodules and dependencies
3. **Builds for All Platforms**: Compiles for iOS device, iOS Simulator (arm64 and x86_64)
4. **Creates XCFrameworks**: Combines slices into multi-architecture XCFrameworks
5. **Zips Archives**: Compresses XCFrameworks for SPM
6. **Saves to archives/**: Places zipped XCFrameworks in this repo

**Build Script Highlights**:
```bash
# Build for iOS device
xcodebuild archive \
  -workspace SalesforceMobileSDK.xcworkspace \
  -scheme SalesforceSDKCore \
  -destination "generic/platform=iOS" \
  -archivePath archives/ios \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for iOS Simulator (arm64 - Apple Silicon)
xcodebuild archive \
  -workspace SalesforceMobileSDK.xcworkspace \
  -scheme SalesforceSDKCore \
  -destination "generic/platform=iOS Simulator" \
  -archivePath archives/ios-simulator-arm64 \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
xcodebuild -create-xcframework \
  -framework archives/ios.xcarchive/Products/Library/Frameworks/SalesforceSDKCore.framework \
  -framework archives/ios-simulator-arm64.xcarchive/Products/Library/Frameworks/SalesforceSDKCore.framework \
  -framework archives/ios-simulator-x86_64.xcarchive/Products/Library/Frameworks/SalesforceSDKCore.framework \
  -output archives/SalesforceSDKCore.xcframework

# Zip for SPM
cd archives
zip -r SalesforceSDKCore.xcframework.zip SalesforceSDKCore.xcframework
```

## Release Process

The typical workflow for publishing a new SPM distribution:

### 1. Prepare iOS Repo
- Merge changes to `SalesforceMobileSDK-iOS`
- Tag the release: `git tag v13.2.0`
- Push tag: `git push origin v13.2.0`

### 2. Build XCFrameworks
```bash
cd SalesforceMobileSDK-iOS-SPM
./build_xcframeworks.sh -r forcedotcom -b v13.2.0
```

This generates fresh XCFrameworks in `archives/`.

### 3. Update Package.swift
- Update version in comments/metadata
- Verify platform minimums
- Verify dependency versions (SQLCipher, FMDB)

### 4. Test Locally
Create a test Xcode project and add package as local dependency:
```
File → Add Package Dependencies → Add Local...
```

Verify all libraries link and build correctly.

### 5. Commit and Tag
```bash
git add archives/ Package.swift
git commit -m "Release v13.2.0"
git tag 13.2.0  # SPM tag (no 'v' prefix)
git push origin master
git push origin 13.2.0
```

**Important**: SPM uses tags without 'v' prefix (e.g., `13.2.0`, not `v13.2.0`).

### 6. Verify Release
- Check that tag is visible on GitHub
- Test in a new Xcode project by adding package via URL
- Verify Xcode can resolve and download the package

## Libraries Distributed

All iOS SDK libraries are available via this SPM package:

| Product Name | Binary Target | Purpose |
|--------------|---------------|---------|
| **SalesforceAnalytics** | SalesforceAnalytics | Telemetry and event tracking |
| **SalesforceSDKCommon** | SalesforceSDKCommon | Shared utilities, crypto, protocols |
| **SalesforceSDKCore** | SalesforceSDKCore | OAuth, REST API, account management |
| **SmartStore** | SmartStoreWrapper | Encrypted SQLite storage (includes SQLCipher) |
| **MobileSync** | MobileSync | Data synchronization framework |

## Development Workflow

### Normal Development (Not This Repo)

**Important**: You typically **do not** make changes to framework source code in this repo.

**For SDK development**:
1. Make changes in `SalesforceMobileSDK-iOS` repository
2. Test changes in iOS repo
3. During release: Run `build_xcframeworks.sh` to rebuild binaries

### When to Update This Repo

- **New SDK Release**: Build and publish XCFrameworks for new version
- **Package.swift Updates**: Change dependencies or platform requirements
- **Binary Fixes**: Rebuild XCFrameworks if binaries have issues

### Testing SPM Package Locally

Before releasing:

1. **Build XCFrameworks**: Run `build_xcframeworks.sh`
2. **Local Package**: Add as local dependency in test Xcode project
3. **Verify Linking**: Ensure all libraries link without errors
4. **Run App**: Build and run an app using the SDK
5. **Test All Products**: Try each library (Analytics, Core, SmartStore, MobileSync)

## Code Standards

Since this is primarily a binary distribution repo:

### Package.swift Quality
- **Valid Swift**: Ensure proper Swift syntax
- **Correct Platforms**: iOS 17.0+, watchOS 8+, visionOS 2+, macCatalyst 13+
- **Dependency Versions**: Pin exact versions for stability (SQLCipher, FMDB)
- **Binary Paths**: Verify all paths to archives/ are correct
- **Product Names**: Match iOS repo library names

### XCFramework Quality
- **All Architectures**: Include arm64 device + arm64 and x86_64 simulator
- **Module Stability**: Built with `BUILD_LIBRARY_FOR_DISTRIBUTION=YES`
- **No Debug Symbols**: Strip symbols for smaller size (or include dSYMs separately)
- **Zipped Correctly**: Archives must be valid ZIP files

### Version Management
- **Semantic Versioning**: Follow semver (major.minor.patch)
- **Tag Format**: No 'v' prefix (e.g., `13.2.0`, not `v13.2.0`)
- **Consistency**: Match iOS repo version exactly

## Code Review Checklist

When reviewing changes (typically during release):

- [ ] **XCFrameworks built**: All frameworks in archives/ are fresh builds
- [ ] **Package.swift updated**: Version and dependencies are correct
- [ ] **All architectures**: XCFrameworks include device + simulators (arm64, x86_64)
- [ ] **Local testing**: Package tested in Xcode project
- [ ] **Tag format**: SPM tag has no 'v' prefix
- [ ] **Archive sizes**: Zipped archives are reasonable size
- [ ] **No regressions**: Sample app builds and runs with new package
- [ ] **Dependency versions**: SQLCipher and FMDB versions match expectations

## Agent Behavior Guidelines

### Do
- Understand this is a binary distribution repository
- Direct SDK source code changes to `SalesforceMobileSDK-iOS` repo
- Help validate Package.swift syntax and structure
- Verify XCFramework archives are properly built
- Test package locally before committing

### Don't
- Don't make SDK source code changes here (wrong repo)
- Don't publish without human approval
- Don't skip building XCFrameworks (use the script)
- Don't modify XCFrameworks manually (always rebuild from source)
- Don't use 'v' prefix in SPM tags

### Escalation — Stop and Flag for Human Review
- Any publication of new XCFrameworks (release event)
- Package.swift dependency changes
- Platform requirement changes (iOS version, etc.)
- New libraries added to package
- Changes to build script
- SPM tag creation and publication

## Key Domain Concepts

- **Swift Package Manager (SPM)**: Apple's dependency manager built into Xcode
- **Package.swift**: Manifest file describing an SPM package
- **XCFramework**: Binary framework format supporting multiple architectures/platforms
- **Binary Target**: SPM target referencing pre-built binaries (not source)
- **Product**: Public library exposed by an SPM package
- **Module Stability**: Build flag allowing frameworks built with different Swift versions to work together
- **Fat Binary**: Framework containing multiple architectures (replaced by XCFramework)

## Version History

| Version | Release Date | Notes |
|---------|-------------|-------|
| 13.2.0  | Latest      | Current stable |
| 13.1.0  | -           | Previous release |
| 13.0.0  | -           | Major release |

See [iOS repo release notes](https://github.com/forcedotcom/SalesforceMobileSDK-iOS/releases) for detailed version history.

## Related Documentation

- **iOS SDK**: See `SalesforceMobileSDK-iOS/CLAUDE.md` for SDK source development
- **iOS-Specs**: See `SalesforceMobileSDK-iOS-Specs/CLAUDE.md` for CocoaPods distribution
- **Swift Package Manager**: https://swift.org/package-manager/
- **Creating XCFrameworks**: https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle
- **Mobile SDK Developer Guide**: https://developer.salesforce.com/docs/platform/mobile-sdk/guide
