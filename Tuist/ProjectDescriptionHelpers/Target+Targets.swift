import ProjectDescription

extension Target {

    public static func app(dependencies: [TargetDependency]) -> Target {
        .target(name: "KaleyraVideo",
                destinations: .iOS,
                product: .app,
                bundleId: .bundleId(target: "KaleyraVideo"),
                deploymentTargets: .iOS("15.0"),
                infoPlist: .file(path: .relativeToRoot("Info.plist")),
                sources: [.glob(.relativeToRoot("Source/**"), excluding: [.relativeToRoot("Source/SwiftUI-Example/**")])],
                resources: [.glob(pattern: .relativeToRoot("Resources/**"))],
                entitlements: .file(path: .relativeToRoot("Entitlements/SDK Sample.entitlements")),
                dependencies: [.target(name: "BroadcastExtension")] + dependencies
        )
    }

    public static func broadcastExtension(dependencies: [TargetDependency]) -> Target {
        .target(name: "BroadcastExtension",
                destinations: .iOS,
                product: .appExtension,
                bundleId: .bundleId(target: "KaleyraVideo.BroadcastExtension"),
                deploymentTargets: .iOS("15.0"),
                infoPlist: .file(path: .relativeToRoot("BroadcastExtension/Info.plist")),
                sources: [.glob(.relativeToRoot("BroadcastExtension/**"))],
                entitlements: .file(path: .relativeToRoot("BroadcastExtension/BroadcastExtension.entitlements")),
                dependencies: dependencies
        )
    }

    public static func unitTests() -> Target {
        .target(
            name: "KaleyraVideoUnitTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: .bundleId(target: "KaleyraVideoUnitTests"),
            infoPlist: .default,
            sources: [.glob(.relativeToRoot("Tests/UnitTests/**")), .glob(.relativeToRoot("Testing/**"))],
            resources: [],
            dependencies: [.target(name: "KaleyraVideo"), .sdk(name: "XCTest.framework", type: .framework), .external(name: "SwiftHamcrest")],
            settings: .settings(base: ["FRAMEWORK_SEARCH_PATHS": ["$(inherited)", "$(PLATFORM_DIR)/Developer/Library/Frameworks"]])
        )
    }

    public static func integrationTests() -> Target {
        .target(
            name: "KaleyraVideoIntegrationTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: .bundleId(target: "KaleyraVideoIntegrationTests"),
            infoPlist: .default,
            sources: [.glob(.relativeToRoot("Tests/IntegrationTests/**")), .glob(.relativeToRoot("Testing/**"))],
            resources: [],
            dependencies: [.target(name: "KaleyraVideo"), .sdk(name: "XCTest.framework", type: .framework), .external(name: "SwiftHamcrest")],
            settings: .settings(base: ["FRAMEWORK_SEARCH_PATHS": ["$(inherited)", "$(PLATFORM_DIR)/Developer/Library/Frameworks"]])
        )
    }
}

extension String {

    static func bundleId(target: String) -> String {
        "com.kaleyra." + target
    }
}
