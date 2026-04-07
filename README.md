# Swift Package Manager Distribution for Salesforce Mobile SDK for iOS

Pre-built XCFramework distribution of the Salesforce Mobile SDK for iOS, compatible with Swift Package Manager (SPM).

## Overview

This repository provides **pre-built binary frameworks** (XCFrameworks) for the Salesforce Mobile SDK for iOS. It offers an alternative to CocoaPods for integrating the SDK into your Swift projects using Xcode's native Swift Package Manager.

## Installation

### Via Xcode (Recommended)

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/forcedotcom/SalesforceMobileSDK-iOS-SPM.git
   ```
3. Select version or branch (e.g., `13.2.0` or `master`)
4. Choose which libraries to add to your target:
   - **SalesforceAnalytics** - Telemetry and analytics
   - **SalesforceSDKCommon** - Shared utilities
   - **SalesforceSDKCore** - OAuth and REST API
   - **SmartStore** - Encrypted local storage
   - **MobileSync** - Data synchronization

### Via Package.swift

For Swift packages, add this dependency to your `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/forcedotcom/SalesforceMobileSDK-iOS-SPM.git",
        from: "13.2.0"
    )
]
```

Then add products to your targets:

```swift
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "MobileSync", package: "SalesforceMobileSDK-iOS-SPM"),
            .product(name: "SmartStore", package: "SalesforceMobileSDK-iOS-SPM"),
            .product(name: "SalesforceSDKCore", package: "SalesforceMobileSDK-iOS-SPM")
        ]
    )
]
```

## Available Libraries

| Product | Description |
|---------|-------------|
| **SalesforceAnalytics** | Telemetry, instrumentation, and analytics event tracking |
| **SalesforceSDKCommon** | Shared utilities, crypto helpers, and base protocols |
| **SalesforceSDKCore** | OAuth2 authentication, REST client, account management, push notifications |
| **SmartStore** | Encrypted on-device SQLite storage (SQLCipher-backed) |
| **MobileSync** | Bidirectional data sync between device and Salesforce cloud |

## Platform Support

This package supports:

| Platform | Minimum Version |
|----------|----------------|
| **iOS** | 18.0 |
| **watchOS** | 8.0 |
| **visionOS** | 2.0 |
| **macCatalyst** | 13.0 |

## Usage Example

```swift
import SalesforceSDKCore
import MobileSync

// Configure SDK
SalesforceSDKManager.shared.connectedAppId = "YOUR_CONSUMER_KEY"
SalesforceSDKManager.shared.connectedAppCallbackUri = "sfdc://oauth/success"
SalesforceSDKManager.shared.authScopes = ["api", "web", "refresh_token"]

// Launch SDK
SalesforceSDKManager.shared.launch { [weak self] (launchActionList) in
    // SDK is ready
    self?.setupRootViewController()
}

// Use REST API
let request = RestClient.shared.request(
    forQuery: "SELECT Id, Name FROM Account LIMIT 10",
    apiVersion: nil
)

RestClient.shared.send(request: request) { result in
    switch result {
    case .success(let response):
        print("Accounts:", response.asJsonDictionary())
    case .failure(let error):
        print("Error:", error)
    }
}
```

## What's Inside?

This repository contains:

- **Pre-built XCFrameworks**: Binary frameworks for all supported architectures (arm64 device, arm64/x86_64 simulator)
- **Package.swift**: Swift Package Manager manifest
- **Dependencies**: Automatic integration of SQLCipher and FMDB (for SmartStore)

## Architecture Support

Each XCFramework includes slices for:
- **iOS Devices**: arm64 (iPhone, iPad)
- **iOS Simulator**: arm64 (Apple Silicon Macs) + x86_64 (Intel Macs)

## Binary vs Source Distribution

### This Repository (Binary)
- ✅ Faster integration (pre-compiled)
- ✅ Smaller git clone
- ✅ No build time for SDK libraries
- ❌ Cannot debug into SDK source
- ❌ Cannot modify SDK code

### Source Repository
For SDK development or source-level debugging, use:
- [SalesforceMobileSDK-iOS](https://github.com/forcedotcom/SalesforceMobileSDK-iOS) - Source code repository

## Alternative: CocoaPods

If you prefer CocoaPods over Swift Package Manager, see:
- [SalesforceMobileSDK-iOS-Specs](https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs) - CocoaPods specs repository

## Version Compatibility

| SPM Package | iOS SDK | Swift | Xcode | iOS Min |
|------------|---------|-------|-------|---------|
| 14.0.0     | 14.0.0  | 5.0+  | 16+   | 18.0    |
| 13.2.0     | 13.2.0  | 5.0+  | 16+   | 17.0    |
| 13.1.0     | 13.1.0  | 5.0+  | 16+   | 17.0    |
| 13.0.0     | 13.0.0  | 5.0+  | 16+   | 17.0    |

See [release notes](https://github.com/forcedotcom/SalesforceMobileSDK-iOS/releases) for detailed version history.

## Dependencies

This package automatically includes:
- **SQLCipher**: 4.10.0 - SQLite encryption (for SmartStore)
- **FMDB**: 2.7.12-sqlcipher - Objective-C SQLite wrapper

These are managed automatically by Swift Package Manager.

## Documentation

### Getting Started
- **Mobile SDK Developer Guide**: https://developer.salesforce.com/docs/platform/mobile-sdk/guide
- **iOS SDK Guide**: https://developer.salesforce.com/docs/platform/mobile-sdk/guide/ios-get-started.html

### API Reference
- **SalesforceSDKCommon**: https://forcedotcom.github.io/SalesforceMobileSDK-iOS/Documentation/SalesforceSDKCommon/html/index.html
- **SalesforceAnalytics**: https://forcedotcom.github.io/SalesforceMobileSDK-iOS/Documentation/SalesforceAnalytics/html/index.html
- **SalesforceSDKCore**: https://forcedotcom.github.io/SalesforceMobileSDK-iOS/Documentation/SalesforceSDKCore/html/index.html
- **SmartStore**: https://forcedotcom.github.io/SalesforceMobileSDK-iOS/Documentation/SmartStore/html/index.html
- **MobileSync**: https://forcedotcom.github.io/SalesforceMobileSDK-iOS/Documentation/MobileSync/html/index.html

### Guides
- **Mobile SDK Trail**: https://trailhead.salesforce.com/trails/mobile_sdk_intro
- **Swift Package Manager**: https://swift.org/package-manager/

## For SDK Maintainers

### Building XCFrameworks

If you're a maintainer publishing a new release:

```bash
# Clone this repository
git clone https://github.com/forcedotcom/SalesforceMobileSDK-iOS-SPM.git
cd SalesforceMobileSDK-iOS-SPM

# Build XCFrameworks from iOS SDK release
./build_xcframeworks.sh -r forcedotcom -b v13.2.0

# Commit and tag
git add archives/ Package.swift
git commit -m "Release v13.2.0"
git tag 13.2.0  # Note: no 'v' prefix for SPM tags
git push origin master
git push origin 13.2.0
```

**Important**: SPM tags should NOT have a 'v' prefix (e.g., use `13.2.0`, not `v13.2.0`).

## Related Repositories

- **iOS SDK** (source): https://github.com/forcedotcom/SalesforceMobileSDK-iOS
- **iOS Specs** (CocoaPods): https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs
- **iOS Hybrid**: https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Hybrid
- **Templates**: https://github.com/forcedotcom/SalesforceMobileSDK-Templates

## Support

- **Issues**: [GitHub Issues](https://github.com/forcedotcom/SalesforceMobileSDK-iOS-SPM/issues)
- **Questions**: [Salesforce Stack Exchange](https://salesforce.stackexchange.com/questions/tagged/mobilesdk)
- **Community**: [Trailblazer Community](https://trailhead.salesforce.com/trailblazer-community/groups/0F94S000000kH0HSAU)

## License

Salesforce Mobile SDK License. See [LICENSE.md](LICENSE.md) for details.
