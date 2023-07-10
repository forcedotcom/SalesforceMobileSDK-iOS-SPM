// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "SalesforceMobileSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .watchOS(.v8)
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
            url: "https://github.com/wmathurin/SalesforceMobileSDK-iOS-SPM/raw/main/archives/SalesforceAnalytics.xcframework.zip",
            checksum: "57032573bf78e6dd04d3087cce04e571933d7ff6df4f0c33f9b3742658305526" // SalesforceAnalytics
         ),
        .binaryTarget(
            name: "SalesforceSDKCommon",
            url: "https://github.com/wmathurin/SalesforceMobileSDK-iOS-SPM/raw/main/archives/SalesforceSDKCommon.xcframework.zip",
            checksum: "f41efb8aa09f7647a147182f4b4bf2f7223b90cae9abf027b17f4ff3c23670f2" // SalesforceSDKCommon
        ),
        .binaryTarget(
            name: "SalesforceSDKCore",
            url: "https://github.com/wmathurin/SalesforceMobileSDK-iOS-SPM/raw/main/archives/SalesforceSDKCore.xcframework.zip",
            checksum: "742d62a10197326d1f45eedc4eb99af339fa09a05546fbbd55ebc076d014eb00" // SalesforceSDKCore
        ),
        .binaryTarget(
            name: "SmartStore",
            url: "https://github.com/wmathurin/SalesforceMobileSDK-iOS-SPM/raw/main/archives/SmartStore.xcframework.zip",
            checksum: "8e749b90d066ea31eadbeeb811d0c062d52f312a984dde31c1207e09b07da8c5" // SmartStore
        ),
        .binaryTarget(
            name: "MobileSync",
            url: "https://github.com/wmathurin/SalesforceMobileSDK-iOS-SPM/raw/main/archives/MobileSync.xcframework.zip",
            checksum: "dfc1bb3fb5c1d2a268c938abc905fc83ad9254b5da893b084cced1e08c7365d4" // MobileSync
        )
    ],
    swiftLanguageVersions: [.v5]
)