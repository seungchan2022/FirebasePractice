import Foundation

// MARK: - AuthEntity.Me

extension AuthEntity {
  public enum Me { }
}

// MARK: - AuthEntity.Me.Response

extension AuthEntity.Me {
  public struct Response: Equatable, Codable, Sendable {
    public let uid: String
    public let email: String?
    public let userName: String?
    public let photoURL: String?

    public init(
      uid: String,
      email: String?,
      userName: String?,
      photoURL: String?)
    {
      self.uid = uid
      self.email = email
      self.userName = userName
      self.photoURL = photoURL
    }
  }
}
