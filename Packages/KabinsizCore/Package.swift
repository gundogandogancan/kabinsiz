// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KabinsizCore",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "DomainContracts", targets: ["DomainContracts"]),
        .library(name: "WardrobeDomain", targets: ["WardrobeDomain"]),
        .library(name: "LocalStore", targets: ["LocalStore"]),
        .library(name: "TravelEngine", targets: ["TravelEngine"]),
        .library(name: "FitPassport", targets: ["FitPassport"]),
        .library(name: "ShoppingCopilot", targets: ["ShoppingCopilot"]),
    ],
    targets: [
        .target(name: "DomainContracts"),
        .target(name: "WardrobeDomain", dependencies: ["DomainContracts"]),
        .target(name: "LocalStore", dependencies: ["DomainContracts"]),
        .target(name: "TravelEngine", dependencies: ["DomainContracts", "WardrobeDomain"]),
        .target(name: "FitPassport", dependencies: ["DomainContracts"]),
        .target(
            name: "ShoppingCopilot",
            dependencies: ["DomainContracts", "WardrobeDomain", "FitPassport"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "KabinsizCoreTests",
            dependencies: ["DomainContracts", "WardrobeDomain", "LocalStore", "TravelEngine", "FitPassport", "ShoppingCopilot"]
        ),
    ]
)
