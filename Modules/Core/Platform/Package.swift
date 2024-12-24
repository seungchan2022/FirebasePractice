// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Platform",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "Platform",
      targets: ["Platform"]),
  ],
  dependencies: [
    .package(path: "../../Core/Domain"),
    .package(path: "../../Core/Architecture"),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk.git",
      .upToNextMajor(from: "11.6.0")),
    .package(
      url: "https://github.com/google/GoogleSignIn-iOS",
      .upToNextMajor(from: "8.0.0")),
    .package(
      url: "https://github.com/kakao/kakao-ios-sdk.git",
      .upToNextMajor(from: "2.23.0")),
  ],
  targets: [
    .target(
      name: "Platform",
      dependencies: [
        "Domain",
        "Architecture",
        .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
        .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
        .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS"),
        .product(name: "KakaoSDKCommon", package: "kakao-ios-sdk"),
        .product(name: "KakaoSDKAuth", package: "kakao-ios-sdk"),
        .product(name: "KakaoSDKUser", package: "kakao-ios-sdk"),
      ]),
  ])
