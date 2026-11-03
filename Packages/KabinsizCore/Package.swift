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
        .library(name: "SystemContracts", targets: ["SystemContracts"]),
        .library(name: "Vault", targets: ["Vault"]),
        .library(name: "BodyGeometry", targets: ["BodyGeometry"]),
        .library(name: "Octopus", targets: ["Octopus"]),
    ],
    targets: [
        .target(name: "DomainContracts"),
        .target(name: "WardrobeDomain", dependencies: ["DomainContracts"]),
        .target(name: "LocalStore", dependencies: ["DomainContracts"]),
        .target(name: "TravelEngine", dependencies: ["DomainContracts", "WardrobeDomain"]),
        .target(name: "FitPassport", dependencies: ["DomainContracts"]),
        // v1.5 §133.3 shared contracts: events, work orders, registry, egress, evidence, budgets, faults.
        .target(name: "SystemContracts", dependencies: ["DomainContracts"]),
        // v1.5 §111/§116 encrypted PrivateVault: CryptoKit AES-GCM, Keychain KEK, per-domain keys.
        .target(name: "Vault", dependencies: ["SystemContracts", "LocalStore"]),
        // v1.5 §108/§133.1 body truth + neutral covered 2D silhouette (3D mesh is WP15-07/08).
        .target(name: "BodyGeometry"),
        // v1.5 §103 OctopusCoordinator: task DAG, policy, budget, timeouts, latest-wins; body journey.
        .target(name: "Octopus", dependencies: ["DomainContracts", "SystemContracts", "BodyGeometry", "Vault"]),
        .target(
            name: "ShoppingCopilot",
            dependencies: ["DomainContracts", "WardrobeDomain", "FitPassport"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "KabinsizCoreTests",
            dependencies: ["DomainContracts", "WardrobeDomain", "LocalStore", "TravelEngine", "FitPassport", "ShoppingCopilot"]
        ),
        .testTarget(
            name: "ContractTests",
            dependencies: ["SystemContracts", "DomainContracts"],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "OctopusTests",
            dependencies: ["SystemContracts", "BodyGeometry", "Octopus", "Vault"]
        ),
        .testTarget(
            name: "SecurityTests",
            dependencies: ["SystemContracts", "Vault", "LocalStore", "DomainContracts", "WardrobeDomain", "TravelEngine", "FitPassport", "ShoppingCopilot"]
        ),
    ]
)
