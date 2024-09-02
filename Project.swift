import ProjectDescription

let project = Project(
    name: "KaleyraVideo",
    targets: [
        .target(
            name: "KaleyraVideo",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.KaleyraVideo",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["KaleyraVideo/Sources/**"],
            resources: ["KaleyraVideo/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "KaleyraVideoTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.KaleyraVideoTests",
            infoPlist: .default,
            sources: ["KaleyraVideo/Tests/**"],
            resources: [],
            dependencies: [.target(name: "KaleyraVideo")]
        ),
    ]
)
