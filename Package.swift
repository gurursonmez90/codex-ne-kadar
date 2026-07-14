// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CodexNeKadar",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "CodexNeKadar", targets: ["CodexNeKadar"])
    ],
    targets: [
        .executableTarget(
            name: "CodexNeKadar",
            path: "Sources/CodexNeKadar"
        )
    ]
)
