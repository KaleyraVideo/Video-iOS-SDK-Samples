import ProjectDescription

let project = Project(
    name: "KaleyraVideo",
    organizationName: "Kaleyra S.p.a.",
    options: .options(disableBundleAccessors: true, disableSynthesizedResourceAccessors: true),
    targets: [
        .target(
            name: "KaleyraVideo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.kaleyra.KaleyraVideo",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "UIBackgroundModes" : ["audio", "voip", "remote-notification"],
                    "NSCameraUsageDescription" : "Camera",
                    "NSMicrophoneUsageDescription" : "Microphone",
                    "NSPhotoLibraryUsageDescription" : "Photo Library",
                    "ITSAppUsesNonExemptEncryption" : false
                ]
            ),
            sources: ["Source/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: .relativeToRoot("Entitlements/SDK Sample.entitlements")),
            dependencies: [.target(name: "BroadcastExtension"), .external(name: "KaleyraVideoSDK")]
        ),
        .target(name: "BroadcastExtension",
                destinations: .iOS,
                product: .appExtension,
                bundleId: "com.kaleyra.KaleyraVideo.BroadcastExtension",
                infoPlist: .file(path: "BroadcastExtension/Info.plist"),
                sources: ["BroadcastExtension/**"],
                entitlements: "BroadcastExtension/BroadcastExtension.entitlements"),
        .target(
            name: "KaleyraVideoUnitTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.kaleyra.KaleyraVideoUnitTests",
            infoPlist: .default,
            sources: ["Tests/UnitTests/**", "Testing/**"],
            resources: [],
            dependencies: [.target(name: "KaleyraVideo")]
        ),
        .target(
            name: "KaleyraVideoIntegrationTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.kaleyra.KaleyraVideoIntegrationTests",
            infoPlist: .default,
            sources: ["Tests/IntegrationTests/**", "Testing/**"],
            resources: [],
            dependencies: [.target(name: "KaleyraVideo")]
        ),
    ]
)
