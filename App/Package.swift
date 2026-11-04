// swift-tools-version: 5.9
import Foundation
import PackageDescription

// SwiftPM names a local package after its folder, so the parent package's
// identity is whatever the checkout folder is called (for example
// "kids-typing-tutor" on CI). Work it out here so the build does not depend
// on the folder name.
let corePackage = URL(fileURLWithPath: Context.packageDirectory)
    .deletingLastPathComponent()
    .lastPathComponent
    .lowercased()

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
                .product(name: "TypingTutorCore", package: corePackage)
            ],
            path: "Sources/TypingTutor",
            linkerSettings: [
                .linkedFramework("SwiftUI"),
                .linkedFramework("AppKit")
            ]
        )
    ]
)
