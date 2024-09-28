// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SalesforceMobileSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .watchOS(.v8),
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "SalesforceAnalytics",
            targets: ["SalesforceAnalytics"]
        ),
        .library(
            name: "SalesforceSDKCommon",
            targets: ["SalesforceSDKCommon"]
        ),
        .library(
            name: "SalesforceSDKCore",
            targets: ["SalesforceSDKCore"]
        ),
        .library(
            name: "SmartStore",
            targets: ["SmartStore"]
        ),
        .library(
            name: "MobileSync",
            targets: ["MobileSync"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "SalesforceAnalytics",
            path:"archives/SalesforceAnalytics.xcframework.zip"
         ),
        .binaryTarget(
            name: "SalesforceSDKCommon",
            path:"archives/SalesforceSDKCommon.xcframework.zip"
        ),
        .binaryTarget(
            name: "SalesforceSDKCore",
            path:"archives/SalesforceSDKCore.xcframework.zip"
        ),
        .binaryTarget(
            name: "SmartStore",
            path:"archives/SmartStore.xcframework.zip"
        ),
        .binaryTarget(
            name: "MobileSync",
            path:"archives/MobileSync.xcframework.zip"
        )
    ],
    swiftLanguageVersions: [.v5]
)
