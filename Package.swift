// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FoundationPlus",
    platforms: [
        .iOS(.v17),  // Add minimum platform requirement
        .macOS(.v14)  // Add macOS support
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FoundationPlus",
            targets: ["FoundationPlus"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FoundationPlus"),
        .testTarget(
            name: "FoundationPlusTests",
            dependencies: ["FoundationPlus"]
        ),
    ]
)
