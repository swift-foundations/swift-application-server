// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-application-server",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Application Server",
            targets: ["Application Server"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-application.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-server.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-http-redirect.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-http-host.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-server-static.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-json.git", branch: "main"),
        .package(url: "https://github.com/swift-standards/swift-http-standard.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Application Server",
            dependencies: [
                .product(name: "Application", package: "swift-application"),
                .product(name: "Server", package: "swift-server"),
                .product(name: "HTTP Redirect", package: "swift-http-redirect"),
                .product(name: "HTTP Host", package: "swift-http-host"),
                .product(name: "Server Static", package: "swift-server-static"),
                .product(name: "JSON", package: "swift-json"),
                .product(name: "HTTP Standard", package: "swift-http-standard"),
            ]
        ),
        .testTarget(
            name: "Application Server Tests",
            dependencies: [
                "Application Server",
                .product(name: "HTTP Standard", package: "swift-http-standard"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
