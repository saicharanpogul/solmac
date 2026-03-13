// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Solmac",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Solmac",
            path: "Sources/Solmac"
        )
    ]
)
