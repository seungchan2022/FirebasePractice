import Foundation

public protocol TodoListUseCase: Sendable {

  var addCategoryItem: (String, TodoListEntity.Category.Item) async throws -> Bool { get }

  var getCategoryItem: (String, String) async throws -> TodoListEntity.Category.Item { get }

  var getCategoryItemList: (String) async throws -> [TodoListEntity.Category.Item] { get }

  var addTodoItem: (String, String, TodoListEntity.TodoItem.Item) async throws -> Bool { get }

  var getTodoItem: (String, String, String) async throws -> TodoListEntity.TodoItem.Item { get }

  var getTodoItemList: (String, String) async throws -> [TodoListEntity.TodoItem.Item] { get }

  var updateTodoItemStatus: (String, String, String, Bool) async throws -> TodoListEntity.TodoItem.Item { get }

  var updateMemo: (String, String, String, String) async throws -> TodoListEntity.TodoItem.Item { get }

  var deleteTodoItem: (TodoListEntity.TodoItem.Item) async throws -> Bool { get }

  var editTodoItemTitle: (TodoListEntity.TodoItem.Item, String) async throws -> TodoListEntity.TodoItem.Item { get }
}
