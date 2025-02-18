import Foundation

public protocol TodoListUseCase: Sendable {

  var addCategoryItem: (String, String) async throws -> TodoListEntity.Category.Item { get }

  var getCategoryItem: (String, String) async throws -> TodoListEntity.Category.Item { get }

  var getCategoryItemList: (String) async throws -> [TodoListEntity.Category.Item] { get }

  var addTodoItem: (String, String, String) async throws -> TodoListEntity.TodoItem.Item { get }

  var getTodoItem: (String, String, String) async throws -> TodoListEntity.TodoItem.Item { get }

  var getTodoItemList: (String, String) async throws -> [TodoListEntity.TodoItem.Item] { get }

  var updateTodoItemStatus: (TodoListEntity.TodoItem.Item, Bool) async throws -> TodoListEntity.TodoItem.Item { get }

  var updateMemo: (TodoListEntity.TodoItem.Item, String) async throws -> TodoListEntity.TodoItem.Item { get }

  var deleteTodoItem: (TodoListEntity.TodoItem.Item) async throws -> Bool { get }

  var editTodoItemTitle: (TodoListEntity.TodoItem.Item, String) async throws -> TodoListEntity.TodoItem.Item { get }

  var deleteCategoryItem: (TodoListEntity.Category.Item) async throws -> Bool { get }

  var editCategoryItemTitle: (TodoListEntity.Category.Item, String) async throws -> TodoListEntity.Category.Item { get }
}
