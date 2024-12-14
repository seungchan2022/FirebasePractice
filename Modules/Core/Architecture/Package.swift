// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Architecture",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "Architecture",
      targets: ["Architecture"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMajor(from: "1.17.0")),
    .package(
      url: "https://github.com/forXifLess/LinkNavigator.git",
      .upToNextMajor(from: "1.3.0")),
  ],
  targets: [
    .target(
      name: "Architecture",
      dependencies: [
        .product(name: "LinkNavigator", package: "LinkNavigator"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]),
  ])
