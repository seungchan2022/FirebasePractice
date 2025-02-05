import Architecture
import Domain
import FirebaseAuth
import FirebaseFirestore

// MARK: - TodoListUseCasePlatform

public struct TodoListUseCasePlatform {
  public init() { }
}

// MARK: TodoListUseCase

extension TodoListUseCasePlatform: TodoListUseCase {

  public var addCategoryItem: (String, TodoListEntity.Category.Item) async throws -> Bool {
    { uid, item in
      do {
        try await addCategoryItem(uid: uid, item: item)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var getCategoryItem: (String, String) async throws -> TodoListEntity.Category.Item {
    { uid, categoryId in
      do {
        return try await Firestore.firestore()
          .collection("users")
          .document(uid)
          .collection("category_list")
          .document(categoryId)
          .getDocument(as: TodoListEntity.Category.Item.self)

      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var getCategoryItemList: (String) async throws -> [TodoListEntity.Category.Item] {
    { uid in
      do {
        return try await Firestore.firestore().collection("users")
          .document(uid)
          .collection("category_list")
          .order(by: "date_created", descending: false)
          .getDocuments(as: TodoListEntity.Category.Item.self)

//        return try snapshot.documents.compactMap { doc in
//          try doc.data(as: TodoListEntity.Category.Item.self)
//        }

      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var addTodoItem: (String, String, TodoListEntity.TodoItem.Item) async throws -> Bool {
    { uid, categoryId, item in
      do {
        try await addTodoItem(uid: uid, categoryId: categoryId, item: item)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var getTodoItem: (String, String, String) async throws -> TodoListEntity.TodoItem.Item {
    { uid, categoryId, todoId in
      do {
        return try await Firestore.firestore()
          .collection("users")
          .document(uid)
          .collection("category_list")
          .document(categoryId)
          .collection("todo_list")
          .document(todoId)
          .getDocument(as: TodoListEntity.TodoItem.Item.self)

      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var getTodoItemList: (String, String) async throws -> [TodoListEntity.TodoItem.Item] {
    { uid, categoryId in
      do {
        return try await Firestore.firestore()
          .collection("users")
          .document(uid)
          .collection("category_list")
          .document(categoryId)
          .collection("todo_list")
          .order(by: "date_created", descending: false)
          .getDocuments(as: TodoListEntity.TodoItem.Item.self)

      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }
//
//  public var getTodoItemList: (String, String) async throws -> [TodoListEntity.TodoItem.Item] {
//    { uid, categoryId in
//      do {
//        let snapshot = try await Firestore.firestore()
//          .collection("users")
//          .document(uid)
//          .collection("category_list")
//          .document(categoryId)
//          .collection("todo_list")
//          .getDocuments()
//
//        return try snapshot.documents.compactMap { doc in
//          try doc.data(as: TodoListEntity.TodoItem.Item.self)
//        }
//      } catch {
//        throw CompositeErrorRepository.other(error)
//      }
//    }
//  }

}

extension TodoListUseCasePlatform {
  func addCategoryItem(uid: String, item: TodoListEntity.Category.Item) async throws {
    let docRef = Firestore.firestore()
      .collection("users")
      .document(uid)
      .collection("category_list")
      .document(item.id)

    try docRef.setData(from: item, merge: true)
  }

  func addTodoItem(uid: String, categoryId: String, item: TodoListEntity.TodoItem.Item) async throws {
    let docRef = Firestore.firestore()
      .collection("users")
      .document(uid)
      .collection("category_list")
      .document(categoryId)
      .collection("todo_list")
      .document(item.id)

    try docRef.setData(from: item, merge: true)
  }
}

// MARK: - FirestoreTodoRepository

/// Firestore를 통해 카테고리와 투두 아이템을 관리하는 Repository 예시
struct FirestoreTodoRepository {

  // MARK: Internal

  // MARK: - 카테고리 추가
  /// 특정 유저의 카테고리를 추가합니다.
  /// - Parameters:
  ///   - userId: 유저의 ID
  ///   - category: 추가할 카테고리 (TodoList.Category.Item)
  func addCategory(for userId: String, category: TodoListEntity.Category.Item) async throws {
    // 경로: /users/{userId}/categories/{categoryId}
    let docRef = db.collection("users")
      .document(userId)
      .collection("categories")
      .document(category.id)

    try docRef.setData(from: category, merge: true)
  }

  // MARK: - 투두 아이템 추가
  /// 특정 유저의 특정 카테고리 안에 투두 아이템을 추가합니다.
  /// - Parameters:
  ///   - userId: 유저의 ID
  ///   - categoryId: 해당 카테고리의 ID
  ///   - todo: 추가할 투두 아이템 (TodoList.TodoItem.Item)
  func addTodo(for userId: String, categoryId: String, todo: TodoListEntity.TodoItem.Item) async throws {
    // 경로: /users/{userId}/categories/{categoryId}/todos/{todoId}
    let docRef = db.collection("users")
      .document(userId)
      .collection("categories")
      .document(categoryId)
      .collection("todos")
      .document(todo.id)

    try docRef.setData(from: todo, merge: true)
  }

  // MARK: - 카테고리 목록 가져오기
  /// 특정 유저의 모든 카테고리를 가져옵니다.
  /// - Parameter userId: 유저의 ID
  /// - Returns: TodoList.Category.Item 배열
  func fetchCategories(for userId: String) async throws -> [TodoListEntity.Category.Item] {
    // 경로: /users/{userId}/categories
    let snapshot = try await db.collection("users")
      .document(userId)
      .collection("categories")
      .getDocuments()

    return try snapshot.documents.compactMap { doc in
      try doc.data(as: TodoListEntity.Category.Item.self)
    }
  }

  // MARK: - 특정 카테고리의 투두 목록 가져오기
  /// 특정 유저의 특정 카테고리 내의 모든 투두 아이템을 가져옵니다.
  /// - Parameters:
  ///   - userId: 유저의 ID
  ///   - categoryId: 카테고리의 ID
  /// - Returns: TodoList.TodoItem.Item 배열
  func fetchTodos(for userId: String, categoryId: String) async throws -> [TodoListEntity.TodoItem.Item] {
    // 경로: /users/{userId}/categories/{categoryId}/todos
    let snapshot = try await db.collection("users")
      .document(userId)
      .collection("categories")
      .document(categoryId)
      .collection("todos")
      .getDocuments()

    return try snapshot.documents.compactMap { doc in
      try doc.data(as: TodoListEntity.TodoItem.Item.self)
    }
  }

  // MARK: Private

  private let db = Firestore.firestore()

}
