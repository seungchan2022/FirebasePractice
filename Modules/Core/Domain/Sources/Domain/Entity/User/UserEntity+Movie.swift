import Foundation

// MARK: - UserEntity.Movie

extension UserEntity {
  public enum Movie { }
}

// MARK: - UserEntity.Movie.Item

extension UserEntity.Movie {
  public struct Item: Equatable, Codable, Sendable {
    public let id: String
    public let title: String
    public let isPopular: Bool

    public init(
      id: String,
      title: String,
      isPopular: Bool)
    {
      self.id = id
      self.title = title
      self.isPopular = isPopular
    }

    private enum CodingKeys: String, CodingKey {
      case id
      case title
      case isPopular = "is_popular"
    }
  }
}
