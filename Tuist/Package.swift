// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
//        productTypes: ["KaleyraVideoSDK" : .framework]
    )
#endif

let package = Package(
    name: "KaleyraVideo",
    dependencies: [
//        .package(url: "https://github.com/KaleyraVideo/VideoiOSSDK", exact: "4.0.0-alpha.1")
    ]
)
