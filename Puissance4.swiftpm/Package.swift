// swift-tools-version: 5.9

// Projet d'application iPad : s'ouvre dans Xcode (Mac) ou directement
// dans l'app Swift Playgrounds sur iPad.
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Puissance4",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Puissance 4",
            targets: ["AppModule"],
            bundleIdentifier: "com.sebastienblin.puissance4",
            displayVersion: "1.0",
            bundleVersion: "1",
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources"
        )
    ]
)
