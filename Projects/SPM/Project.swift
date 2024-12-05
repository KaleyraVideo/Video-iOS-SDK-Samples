import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "KaleyraVideo",
    organizationName: "Kaleyra S.p.a.",
    options: .options(disableBundleAccessors: true, disableSynthesizedResourceAccessors: true),
    targets: [
        .app(dependencies: [.external(name: "KaleyraVideoSDK")]),
        .broadcastExtension(dependencies: [.external(name: "KaleyraVideoBroadcastExtension")]),
        .unitTests(),
        .integrationTests()
    ]
)
