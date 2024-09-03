import ProjectDescription

let project = Project(
    name: "KaleyraVideo",
    organizationName: "Kaleyra S.p.a.",
    options: .options(disableBundleAccessors: true, disableSynthesizedResourceAccessors: true),
    targets: [
        .target(name: "KaleyraVideo",
                destinations: .iOS,
                product: .app,
                bundleId: "com.kaleyra.KaleyraVideo",
                deploymentTargets: .iOS("15.0"),
                infoPlist: .file(path: .relativeToRoot("Info.plist")),
                sources: [.glob(.relativeToRoot("Source/**"), excluding: [.relativeToRoot("Source/SwiftUI-Example/**")])],
                resources: [.glob(pattern: .relativeToRoot("Resources/**"))],
                entitlements: .file(path: .relativeToRoot("Entitlements/SDK Sample.entitlements")),
                dependencies: [.target(name: "BroadcastExtension"), .external(name: "KaleyraVideoSDK")]
        ),
        .target(name: "BroadcastExtension",
                destinations: .iOS,
                product: .appExtension,
                bundleId: "com.kaleyra.KaleyraVideo.BroadcastExtension",
                deploymentTargets: .iOS("15.0"),
                infoPlist: .file(path: .relativeToRoot("BroadcastExtension/Info.plist")),
                sources: [.glob(.relativeToRoot("BroadcastExtension/**"))],
                entitlements: .file(path: .relativeToRoot("BroadcastExtension/BroadcastExtension.entitlements")),
                dependencies: [.external(name: "BandyerBroadcastExtension")]
        ),
        .target(name: "KaleyraVideoUnitTests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "com.kaleyra.KaleyraVideoUnitTests",
                infoPlist: .default,
                sources: [.glob(.relativeToRoot("Tests/UnitTests/**")), .glob(.relativeToRoot("Testing/**"))],
                resources: [],
                dependencies: [.target(name: "KaleyraVideo")]
        ),
        .target(name: "KaleyraVideoIntegrationTests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "com.kaleyra.KaleyraVideoIntegrationTests",
                infoPlist: .default,
                sources: [.glob(.relativeToRoot("Tests/IntegrationTests/**")), .glob(.relativeToRoot("Testing/**"))],
                resources: [],
                dependencies: [.target(name: "KaleyraVideo")]
        )
    ]
)
