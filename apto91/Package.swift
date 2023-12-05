// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "apto91",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.83.1"),
        
        // 🐘 Non-blocking, event-driven Swift client for PostgreSQL
        .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "PostgresKit", package: "postgres-kit"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),

            // Workaround for https://github.com/apple/swift-package-manager/issues/6940
            .product(name: "Vapor", package: "vapor"),
        ])
    ]
)
