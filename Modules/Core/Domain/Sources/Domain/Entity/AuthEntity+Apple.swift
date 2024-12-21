import Foundation

// MARK: - AuthEntity.Apple

extension AuthEntity {
  public enum Apple { }
}

// MARK: - AuthEntity.Apple.Response

extension AuthEntity.Apple {
  public struct Response: Equatable, Codable, Sendable {
    public let token: String
    public let nonce: String
    public let name: String?

    public init(
      token: String,
      nonce: String,
      name: String?)
    {
      self.token = token
      self.nonce = nonce
      self.name = name
    }
  }
}
