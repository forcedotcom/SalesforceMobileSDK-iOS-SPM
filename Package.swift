// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SalesforceMobileSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .watchOS(.v8),
        .visionOS(.v2),
        .macCatalyst(.v13)
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
            targets: ["SmartStoreWrapper"]
        ),
        .library(
            name: "MobileSync",
            targets: ["MobileSync"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sqlcipher/SQLCipher.swift.git", exact: "4.10.0"),
        .package(url: "https://github.com/forcedotcom/fmdb.git", branch: "spm")
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
            name: "SmartStoreBinary",
            path:"archives/SmartStore.xcframework.zip"
        ),
        .binaryTarget(
            name: "MobileSync",
            path:"archives/MobileSync.xcframework.zip"
        ),
        .target(
            name: "SmartStoreWrapper",
            dependencies: [
                "SmartStoreBinary",
                .product(name: "SQLCipher", package: "SQLCipher.swift"),
                .product(name: "FMDB", package: "fmdb")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
