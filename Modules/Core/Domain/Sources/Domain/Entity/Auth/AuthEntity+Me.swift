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
      email: String? = .none,
      userName: String? = .none,
      photoURL: String? = .none,
      created: Date? = .none)
    {
      self.uid = uid
      self.email = email
      self.userName = userName
      self.photoURL = photoURL
      self.created = created
    }

    // MARK: Public

    public let uid: String
    public let email: String?
    public let userName: String?
    public let photoURL: String?
    public let created: Date?

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case uid
      case email
      case userName = "user_name"
      case photoURL = "photo_url"
      case created

    }
  }
}
