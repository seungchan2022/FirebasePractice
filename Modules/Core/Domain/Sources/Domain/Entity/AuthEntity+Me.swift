import Foundation

// MARK: - AuthEntity.Me

extension AuthEntity {
  public enum Me { }
}

// MARK: - AuthEntity.Me.Response

extension AuthEntity.Me {
  public struct Response: Equatable, Codable, Sendable {

    // MARK: Lifecycle

    public init(
      uid: String,
      email: String?,
      userName: String?,
      photoURL: String?,
      created: Date?,
      isPremium: Bool?)
    {
      self.uid = uid
      self.email = email
      self.userName = userName
      self.photoURL = photoURL
      self.created = created
      self.isPremium = isPremium
    }

    // MARK: Public

    public let uid: String
    public let email: String?
    public let userName: String?
    public let photoURL: String?
    public let created: Date?
    public let isPremium: Bool?

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case uid
      case email
      case userName = "user_name"
      case photoURL
      case created
      case isPremium = "is_premium"
    }
  }
}
