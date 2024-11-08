// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: ["KaleyraVideoSDK" : .framework,
                       "BandyerBroadcastExtension" : .framework,
                       "SwiftHamcrest" : .framework],
        targetSettings: ["SwiftHamcrest" : ["OTHER_LDFLAGS": ["$(inherited)", "-framework XCTest"]]]
    )
#endif

let package = Package(
    name: "KaleyraVideo",
    dependencies: [
        .package(url: "https://github.com/KaleyraVideo/VideoiOSSDK", exact: "4.0.0"),
        .package(url: "https://github.com/KaleyraVideo/VideoiOSBroadcastExtension", exact: "1.2.0"),
        .package(url: "https://github.com/nschum/SwiftHamcrest", .upToNextMajor(from: "2.2.1"))
    ]
)
