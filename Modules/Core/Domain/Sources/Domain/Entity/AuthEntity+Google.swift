import Foundation

// MARK: - AuthEntity.Google

extension AuthEntity {
  public enum Google { }
}

// MARK: - AuthEntity.Google.Response

extension AuthEntity.Google {
  public struct Response: Equatable, Codable, Sendable {
    public let idToken: String
    public let accessToken: String

    public init(
      idToken: String,
      accessToken: String)
    {
      self.idToken = idToken
      self.accessToken = accessToken
    }
  }
}
