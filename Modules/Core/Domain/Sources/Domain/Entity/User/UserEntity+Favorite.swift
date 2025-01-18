import Foundation

// MARK: - UserEntity.Favorite

extension UserEntity {
  public enum Favorite { }
}

// MARK: - UserEntity.Favorite.Item

extension UserEntity.Favorite {
  public struct Item: Equatable, Codable, Sendable, Identifiable {

    // MARK: Lifecycle

    public init(
      id: String,
      productId: Int,
      dateCreated: Date)
    {
      self.id = id
      self.productId = productId
      self.dateCreated = dateCreated
    }

    // MARK: Public

    public let id: String // documentID (자동 생성되는 ID)
    public let productId: Int // product 아이템의 ID
    public let dateCreated: Date

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case id
      case productId = "product_id"
      case dateCreated = "date_created"
    }

  }
}
