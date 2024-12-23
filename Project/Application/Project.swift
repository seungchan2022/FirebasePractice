import ProjectDescription
import ProjectDescriptionHelpers

let targetList: [Target] = [
  .target(
    name: "FirebasePractice",
    destinations: .iOS,
    product: .app,
    productName: "FirebasePractice",
    bundleId: "io.seungchan.firebasePracticeDemo",
    deploymentTargets: .iOS("18.0"),
    infoPlist: .extendingDefault(with: .compositeValue),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    copyFiles: .none,
    headers: .none,
    entitlements: .dictionary([
      "com.apple.developer.applesignin": .array([
        .string("Default"),
      ]),
    ]),
    scripts: [],
    dependencies: .compositeValue,
    settings: .defaultSettings,
    coreDataModels: [],
    environmentVariables: [:],
    launchArguments: [],
    additionalFiles: [],
    buildRules: [],
    mergedBinaryType: .automatic,
    mergeable: false,
    onDemandResourcesTags: .none),
]

let project: Project = .init(
  name: "FirebasePractice",
  organizationName: "SeungChanMoon",
  classPrefix: .none,
  options: .options(
    automaticSchemesOptions: .enabled(),
    defaultKnownRegions: .none,
    developmentRegion: .none,
    disableBundleAccessors: false,
    disableShowEnvironmentVarsInScriptPhases: false,
    disableSynthesizedResourceAccessors: false,
    textSettings: .textSettings(),
    xcodeProjectName: .none),
  packages: .compositeValue,
  settings: .none,
  targets: targetList,
  schemes: [],
  fileHeaderTemplate: .none,
  additionalFiles: [],
  resourceSynthesizers: .default)

extension [String: Plist.Value] {
  static var compositeValue: [String: Plist.Value] {
    [
      "CFBundleShortVersionString": .string(.appVersion()),
      "CFBundleIdentifier": .string("$(PRODUCT_BUNDLE_IDENTIFIER)"),
      "CFBundleName": .string("${PRODUCT_NAME}"),
      "CFBundleInfoDictionaryVersion": "6.0",
      "CFBundleVersion": .string(.appBuildVersion()),
      "UILaunchScreen": .dictionary([:]),
      "GIDClientID": .string("${CLIENT_ID}"),
      "REVERSED_CLIENT_ID": .string("${REVERSED_CLIENT_ID}"),
      "CFBundleURLTypes": .array([
        .dictionary([
          "CFBundleTypeRole": .string("Editor"),
          "CFBundleURLSchemes": .array([
            .string("${REVERSED_CLIENT_ID}"),
          ]),
        ]),
        .dictionary([
          "CFBundleTypeRole": .string("Editor"),
          "CFBundleURLSchemes": .array([
            .string("${KAKAO_NATIVE_APP_KEY}"),
          ]),
        ]),
      ]),
      "DEVELOPMENT_TEAM": .string("${DEVELOPMENT_TEAM}"),
      "KAKAO_NATIVE_APP_KEY": .string("${KAKAO_NATIVE_APP_KEY}"),
      "LSApplicationQueriesSchemes": .array([
        .string("kakaokompassauth"),
        .string("kakaolink"),
      ]),
    ]
  }
}

extension [TargetDependency] {
  static var compositeValue: [TargetDependency] {
    [
      .package(product: "Architecture", type: .runtime, condition: .none),
      .package(product: "Domain", type: .runtime, condition: .none),
      .package(product: "Platform", type: .runtime, condition: .none),
      .package(product: "Dashboard", type: .runtime, condition: .none),
      .package(product: "Functor", type: .runtime, condition: .none),
      .package(product: "DesignSystem", type: .runtime, condition: .none),
    ]
  }
}

extension [Package] {
  static var compositeValue: [Package] {
    [
      .local(path: .relativeToRoot("Modules/Core/Architecture")),
      .local(path: .relativeToRoot("Modules/Core/Domain")),
      .local(path: .relativeToRoot("Modules/Core/Platform")),
      .local(path: .relativeToRoot("Modules/Feature/Dashboard")),
      .local(path: .relativeToRoot("Modules/Core/Functor")),
      .local(path: .relativeToRoot("Modules/Core/DesignSystem")),
    ]
  }
}
