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
      email: String?,
      userName: String?,
      photoURL: String?,
      created: Date?)
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
