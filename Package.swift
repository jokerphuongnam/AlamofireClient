// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlamofireClient",
    platforms: [
       .macOS(.v10_15),
       .iOS(.v13),
       .tvOS(.v13),
       .watchOS(.v6),
       .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "AlamofireClient",
            targets: ["AlamofireClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0"),
        .package(url: "https://github.com/jokerphuongnam/NetworkManager.git", from: "0.0.0"),
    ],
    targets: [
        .target(
            name: "AlamofireClient",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "NetworkManager", package: "NetworkManager"),
            ]
        ),
        .testTarget(
            name: "AlamofireClientTests",
            dependencies: ["AlamofireClient"]
        ),
    ]
)
