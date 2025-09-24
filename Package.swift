// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EOS-Swift",
    platforms: [
      .macOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EOS-Swift",
            targets: ["EOS-Swift"]
        ),
    ],
    dependencies: [
      .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EOS-Swift",
            dependencies: [
              .product(name: "Yams", package: "Yams")
            ]
        ),
        .testTarget(
            name: "EOS-SwiftTests",
            dependencies: ["EOS-Swift"]
        ),
    ]
)
