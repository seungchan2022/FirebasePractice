import Foundation

public protocol TodoListUseCase: Sendable {

  var addCategoryItem: (String, TodoListEntity.Category.Item) async throws -> Bool { get }

  var getCategoryItem: (String, String) async throws -> TodoListEntity.Category.Item { get }

  var getCategoryItemList: (String) async throws -> [TodoListEntity.Category.Item] { get }
}
