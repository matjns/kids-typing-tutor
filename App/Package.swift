// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TypingTutorApp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TypingTutor", targets: ["TypingTutor"])
    ],
    dependencies: [
        .package(path: "..")
    ],
    targets: [
        .executableTarget(
            name: "TypingTutor",
            dependencies: [
                .product(name: "TypingTutorCore", package: "TypingTutor")
            ],
            path: "Sources/TypingTutor",
            linkerSettings: [
                .linkedFramework("SwiftUI"),
                .linkedFramework("AppKit")
            ]
        )
    ]
)
