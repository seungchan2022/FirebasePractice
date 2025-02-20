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
      isPremium: Bool? = .none,
      wishList: [String]? = .none,
      movie: UserEntity.Movie.Item? = .none,
      profileImagePath: String? = .none,
      profileImagePathURL: String? = .none,
      groupList: [String]? = .none)
    {
      self.uid = uid
      self.email = email
      self.userName = userName
      self.photoURL = photoURL
      self.created = created
      self.isPremium = isPremium
      self.wishList = wishList
      self.movie = movie
      self.profileImagePath = profileImagePath
      self.profileImagePathURL = profileImagePathURL
      self.groupList = groupList
    }

    // MARK: Public

    public let uid: String
    public let email: String?
    public let userName: String?
    public let photoURL: String?
    public let created: Date?
    public let isPremium: Bool?
    public let wishList: [String]?
    public let movie: UserEntity.Movie.Item?
    public let profileImagePath: String?
    public let profileImagePathURL: String?
    public let groupList: [String]?

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case uid
      case email
      case userName = "user_name"
      case photoURL = "photo_url"
      case created
      case isPremium = "is_premium"
      case wishList = "wish_list"
      case movie
      case profileImagePath = "profile_image_path"
      case profileImagePathURL = "profile_image_path_url"
      case groupList = "group_list"
    }
  }
}
