// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Dashboard",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "Dashboard",
      targets: ["Dashboard"]),
  ],
  dependencies: [
    .package(path: "../../Core/Architecture"),
    .package(path: "../../Core/Domain"),
    .package(path: "../../Core/DesignSystem"),
  ],
  targets: [
    .target(
      name: "Dashboard",
      dependencies: [
        "Architecture",
        "Domain",
        "DesignSystem",
      ]),
  ])
