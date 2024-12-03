// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "adventure",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
      // .package(url: "https://github.com/Swiftline/Swiftline.git", from: "0.5.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(name: "adventure", resources: [
            .process("Resources/"),
//            .process("Resources/maps/starting_village/blacksmith.json"),
//            .process("Resources/maps/starting_village/builder.json"),
//            .process("Resources/maps/starting_village/carpenter.json"),
//            .process("Resources/maps/starting_village/castle.json"),
//            .process("Resources/maps/starting_village/farm.json"),
//            .process("Resources/maps/starting_village/hospital.json"),
//            .process("Resources/maps/starting_village/house.json"),
//            .process("Resources/maps/starting_village/hunting_area.json"),
//            .process("Resources/maps/starting_village/inventor.json"),
//            .process("Resources/maps/starting_village/mine.json"),
//            .process("Resources/maps/starting_village/potter.json"),
//            .process("Resources/maps/starting_village/restaurant.json"),
//            .process("Resources/maps/starting_village/shop.json"),
//            .process("Resources/maps/starting_village/main.json")
        ]),
    ]

)
