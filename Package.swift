// swift-tools-version: 5.9
import PackageDescription

// Logic, lessons, and scores live here so tests can run on Linux.
// The Mac app is a separate package under App/ and is not built on Linux.
let package = Package(
    name: "TypingTutor",
    products: [
        .library(name: "TypingTutorCore", targets: ["TypingTutorCore"])
    ],
    targets: [
        .target(name: "TypingTutorCore"),
        .testTarget(
            name: "TypingTutorCoreTests",
            dependencies: ["TypingTutorCore"]
        )
    ]
)
