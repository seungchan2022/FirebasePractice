import ProjectDescription
import ProjectDescriptionHelpers
let targetList: [Target] = [
  .target(
    name: "FirebasePractice",
    destinations: .iOS,
    product: .app,
    productName: "Grab",
    bundleId: "io.seungchan.firebasePractice",
    deploymentTargets: .iOS("18.0"),
    infoPlist: .extendingDefault(with: .compositeValue),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    copyFiles: .none,
    headers: .none,
    entitlements: .none,
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
    ]
  }
}

extension [TargetDependency] {
  static var compositeValue: [TargetDependency] {
    [
    ]
  }
}

extension [Package] {
  static var compositeValue: [Package] {
    [
    ]
  }
}
