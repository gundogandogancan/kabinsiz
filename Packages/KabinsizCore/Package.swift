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
        .library(name: "DomainSchemas", targets: ["DomainSchemas"]),
        .library(name: "LiveMirror", targets: ["LiveMirror"]),
        .library(name: "DesignTokens", targets: ["DesignTokens"]),
        .library(name: "AvatarDressing", targets: ["AvatarDressing"]),
        .library(name: "TodayOutfit", targets: ["TodayOutfit"]),
        .library(name: "LivingWorld", targets: ["LivingWorld"]),
        .library(name: "MorningReady", targets: ["MorningReady"]),
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
        // v1.7 §4 / R17-02 + R18-WP02: versioned product, fabric, body v2, fit, thermal, try-on and commerce DTOs.
        .target(name: "DomainSchemas", dependencies: ["DomainContracts", "SystemContracts", "BodyGeometry"]),
        // LM21-WP03 / ADR-008: live mirror contracts, state machine, admission policy, frame guard. No camera code yet.
        .target(name: "LiveMirror", dependencies: ["DomainContracts", "SystemContracts", "DomainSchemas"]),
        .target(name: "DesignTokens"),
        .target(name: "AvatarDressing", dependencies: ["DomainContracts", "BodyGeometry"]),
        .target(name: "LivingWorld"),
        .target(name: "TodayOutfit", dependencies: ["AvatarDressing", "DomainContracts", "WardrobeDomain", "TravelEngine"]),
        // v2.8 §05 morning-ready: daily planner, versioned cache, weather freshness, reconciler, warm start.
        .target(name: "MorningReady", dependencies: ["AvatarDressing", "LivingWorld", "TodayOutfit", "TravelEngine", "WardrobeDomain"]),
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
            dependencies: ["SystemContracts", "DomainContracts", "DomainSchemas", "BodyGeometry"],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "OctopusTests",
            dependencies: ["SystemContracts", "BodyGeometry", "Octopus", "Vault"]
        ),
        .testTarget(
            name: "LiveMirrorTests",
            dependencies: ["LiveMirror", "DomainSchemas", "SystemContracts", "DomainContracts"]
        ),
        .testTarget(name: "DesignTokensTests", dependencies: ["DesignTokens"]),
        .testTarget(name: "MorningReadyTests", dependencies: ["MorningReady", "AvatarDressing", "LivingWorld", "TodayOutfit", "TravelEngine", "WardrobeDomain"]),
        .testTarget(name: "LivingWorldTests", dependencies: ["AvatarDressing", "TodayOutfit", "LivingWorld", "BodyGeometry", "DomainContracts", "WardrobeDomain", "TravelEngine"]),
        .testTarget(
            name: "SecurityTests",
            dependencies: ["SystemContracts", "Vault", "LocalStore", "DomainContracts", "WardrobeDomain", "TravelEngine", "FitPassport", "ShoppingCopilot"]
        ),
    ]
)
