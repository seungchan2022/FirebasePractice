import Foundation
import ProjectDescription

extension String {
  public static func appVersion() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yy.MM.dd"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: Date())
  }

  public static func appBuildVersion() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMddHHmmsss"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: Date())
  }
}

extension Settings {
  public static var defaultSettings: Settings {
    .settings(
      base: [
        "CODE_SIGN_IDENTITY": "iPhone Developer",
        "CODE_SIGN_STYLE": "Automatic",
        "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
        "SWIFT_VERSION": "6.0",
        "DEVELOPMENT_TEAM": "${DEVELOPMENT_TEAM}",
      ],
      configurations: [
        .debug(
          name: "Debug",
          xcconfig: .relativeToRoot("Project/Application/Resources/Config.xcconfig")),
        .release(
          name: "Release",
          xcconfig: .relativeToRoot("Project/Application/Resources/Config.xcconfig")),

      ],
      defaultSettings: .recommended)
  }
}
