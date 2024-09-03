// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: ["KaleyraVideoSDK" : .framework, "BandyerBroadcastExtension" : .framework]
    )
#endif

let package = Package(
    name: "KaleyraVideo",
    dependencies: [
        .package(url: "https://github.com/KaleyraVideo/VideoiOSSDK", exact: "4.0.0-alpha.1"),
        .package(url: "https://github.com/KaleyraVideo/VideoiOSBroadcastExtension", exact: "1.2.0")
    ]
)
