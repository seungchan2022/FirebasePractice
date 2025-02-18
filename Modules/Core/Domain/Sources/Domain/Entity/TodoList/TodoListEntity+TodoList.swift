import Foundation

extension TodoListEntity {
  public enum Category { }
  public enum TodoItem { }
}

// MARK: - TodoListEntity.Category.Item

extension TodoListEntity.Category {
  public struct Item: Equatable, Codable, Sendable {
    public let id: String
    public let title: String
    public let dateCreated: Date

    public init(
      id: String,
      title: String,
      dateCreated: Date = .now)
    {
      self.id = id
      self.title = title
      self.dateCreated = dateCreated
    }

    private enum CodingKeys: String, CodingKey {
      case id
      case title
      case dateCreated = "date_created"
    }
  }
}

// MARK: - TodoListEntity.TodoItem.Item

extension TodoListEntity.TodoItem {
  public struct Item: Equatable, Codable, Sendable {

    // MARK: Lifecycle

    public init(
      id: String,
      categoryId: String,
      title: String,
      isCompleted: Bool? = .none,
      memo: String? = .none,
      dateCreated: Date = .now)
    {
      self.id = id
      self.categoryId = categoryId
      self.title = title
      self.isCompleted = isCompleted
      self.memo = memo
      self.dateCreated = dateCreated
    }

    // MARK: Public

    public let id: String
    public let categoryId: String
    public let title: String
    public let isCompleted: Bool?
    public let memo: String?
    public let dateCreated: Date

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case id
      case categoryId = "category_id"
      case title
      case isCompleted = "is_completed"
      case memo
      case dateCreated = "date_created"
    }
  }
}
