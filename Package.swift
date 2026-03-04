// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuickNote",
    platforms: [.macOS(.v14)],
    targets: [
        .target(
            name: "QuickNoteCore",
            path: "Sources/QuickNoteCore"
        ),
        .executableTarget(
            name: "QuickNote",
            dependencies: ["QuickNoteCore"],
            path: "Sources/QuickNote"
        ),
        .testTarget(
            name: "QuickNoteCoreTests",
            dependencies: ["QuickNoteCore"],
            path: "Tests/QuickNoteCoreTests"
        )
    ]
)
