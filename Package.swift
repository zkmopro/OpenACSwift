// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenACSwift",
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
            ]
        ),
        .binaryTarget(
            name: "OpenACSwiftBindings",
            url: "https://github.com/zkmopro/zkID/releases/download/latest/MoproiOSBindings.zip",
            checksum: "3e703de17f4e368b63d1966261dad421e9f32e654a9facad086770f192f89d28"
        ),
        .testTarget(
            name: "OpenACSwiftTests",
            dependencies: ["OpenACSwift"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
