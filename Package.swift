// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StatterCRG",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "StatterCRG",
            targets: ["StatterCRG", "StatterCRGUI","StatterBook"]),
        // these are private to the package
//        .executable(name: "treemaker", targets: ["treemaker"]),
//        .plugin(name: "StatterCRGTree", targets: ["CreateTree"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "StatterCRG",
            dependencies: [],
            plugins: [
//                .plugin(name: "CreateTree")
            ]),
        .testTarget(
            name: "StatterCRGTests",
            dependencies: ["StatterCRG"]),
        .target(
            name: "StatterCRGUI",
            dependencies: ["StatterCRG"]),
        .target(
            name: "StatterBook",
            dependencies: ["StatterCRG"]),

// Until Xcode supports multiple targets in a project
// that both use the same SPM which includes a build
// tool we can't use a build tool or those targets
// won't build
        /*
        .plugin(name: "CreateTree",
                capability: .buildTool(),
                dependencies: ["treemaker"]
               ),
         */
            .plugin(name: "GenerateTree", capability: .command(intent: .custom(verb: "generate-tree", description: "Generating Tree Sources"), permissions: [.writeToPackageDirectory(reason: "Generating Tree Sources")]), dependencies: ["treemaker"]),

        .executableTarget(name: "treemaker"),
    ]
)
