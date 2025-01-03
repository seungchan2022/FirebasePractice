import Foundation

// MARK: - UserEntity.User

extension UserEntity {
  public enum User { }
}

// MARK: - UserEntity.User.Response

extension UserEntity.User {
  public struct Response: Equatable, Codable, Sendable {

    // MARK: Lifecycle

    public init(
      uid: String,
      email: String? = .none,
      userName: String? = .none,
      photoURL: String? = .none,
      created: Date? = .none,
      isPremium: Bool? = .none)
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
    public var isPremium: Bool?

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case uid
      case email
      case userName = "user_name"
      case photoURL = "photo_url"
      case created
      case isPremium = "is_premium"
    }
  }
}
