import Foundation

// MARK: - ProductEntity.Product

extension ProductEntity {
  public enum Product { }
}

extension ProductEntity.Product {
  public struct Response: Equatable, Codable, Sendable {
    public let itemList: [Item]
    public let total: Int
    public let skip: Int
    public let limit: Int

    private enum CodingKeys: String, CodingKey {
      case itemList = "products"
      case total
      case skip
      case limit
    }
  }

  public struct Item: Identifiable, Equatable, Codable, Sendable {

    // MARK: Public

    public let id: Int
    public let title: String?
    public let description: String?
    public let category: String?
    public let price: Double?
    public let rating: Double?
    public let tagList: [String]?
    public let reviewList: [ReviewItem]?
    public let imageList: [String]?
    public let thumbnail: String?

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case id
      case title
      case description
      case category
      case price
      case rating
      case tagList = "tags"
      case reviewList = "reviews"
      case imageList = "images"
      case thumbnail
    }
  }

  public struct ReviewItem: Equatable, Codable, Sendable {
    public let rating: Int?
    public let comment: String?
    public let date: String?
    public let name: String?
    public let email: String?

    private enum CodingKeys: String, CodingKey {
      case rating
      case comment
      case date
      case name = "reviewerName"
      case email = "reviewerEmail"
    }
  }
}
