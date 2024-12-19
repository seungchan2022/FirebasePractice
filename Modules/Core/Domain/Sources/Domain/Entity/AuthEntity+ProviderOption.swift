import Foundation

// MARK: - AuthEntity.ProviderOption

extension AuthEntity {
  public enum ProviderOption { }
}

// MARK: - AuthEntity.ProviderOption.Option

extension AuthEntity.ProviderOption {
  public enum Option: String, Equatable, Sendable {
    case email = "password"
    case google = "google.com"
  }
}
