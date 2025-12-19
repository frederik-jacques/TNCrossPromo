// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TNCrossPromo",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "TNCrossPromo",
            targets: ["TNCrossPromo"]
        ),
    ],
    targets: [
        .target(
            name: "TNCrossPromo"
        ),
        .testTarget(
            name: "TNCrossPromoTests",
            dependencies: ["TNCrossPromo"]
        ),
    ]
)
