import Foundation

// MARK: - AuthEntity.Email

extension AuthEntity {
  public enum Email { }
}

// MARK: - AuthEntity.Email.Request

extension AuthEntity.Email {
  public struct Request: Equatable, Codable, Sendable {
    public let email: String
    public let password: String

    public init(
      email: String,
      password: String)
    {
      self.email = email
      self.password = password
    }
  }
}
