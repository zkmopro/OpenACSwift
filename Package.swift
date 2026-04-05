// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenACSwift",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OpenACSwift",
            targets: ["OpenACSwift"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OpenACSwift",
            dependencies: [
                .target(name: "OpenACSwiftBindings")
            ],
            path: "Sources/",
            linkerSettings: [
                .linkedLibrary("c++"),
            ]
        ),
        .binaryTarget(
            name: "OpenACSwiftBindings",
            url: "https://github.com/zkmopro/zkID/releases/download/latest/MoproBindings.xcframework.zip",
            checksum: "cf0a907259ad8509ac0b3ac27becd82fb2a4b92d67a6fa9480636f2884cf5e7d"
        ),
        .testTarget(
            name: "OpenACSwiftTests",
            dependencies: [
                "OpenACSwift",
            ],
            resources: [
                .copy("TestVectors"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
