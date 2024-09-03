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
}

extension String {

    static func bundleId(target: String) -> String {
        "com.kaleyra." + target
    }
}
