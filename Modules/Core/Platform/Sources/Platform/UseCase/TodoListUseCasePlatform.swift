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

  public var updateTodoItemStatus: (String, String, String, Bool) async throws -> TodoListEntity.TodoItem.Item {
    { uid, categoryId, todoId, isCompleted in
      do {
        try await updateTodoItemStatus(uid: uid, categoryId: categoryId, todoId: todoId, isCompleted: isCompleted)
        return try await getTodoItem(uid, categoryId, todoId)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var updateMemo: (String, String, String, String) async throws -> TodoListEntity.TodoItem.Item {
    { uid, categoryId, todoId, memoText in
      do {
        try await updateMemo(uid: uid, categoryId: categoryId, todoId: todoId, memoText: memoText)
        return try await getTodoItem(uid, categoryId, todoId)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var deleteTodoItem: (TodoListEntity.TodoItem.Item) async throws -> Bool {
    { item in
      guard let me = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }

      do {
        try await deleteTodoItem(uid: me.uid, categoryId: item.categoryId, todoId: item.id)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }
}

extension TodoListUseCasePlatform {

  // MARK: Internal

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

  func updateTodoItemStatus(uid: String, categoryId: String, todoId: String, isCompleted: Bool) async throws {
    let data: [String: Any] = [
      "is_completed" : isCompleted,
    ]

    try await Firestore.firestore()
      .collection("users")
      .document(uid)
      .collection("category_list")
      .document(categoryId)
      .collection("todo_list")
      .document(todoId)
      .updateData(data)
  }

  func updateMemo(uid: String, categoryId: String, todoId: String, memoText: String) async throws {
    let data: [String: Any] = [
      "memo": memoText,
    ]

    try await Firestore.firestore()
      .collection("users")
      .document(uid)
      .collection("category_list")
      .document(categoryId)
      .collection("todo_list")
      .document(todoId)
      .updateData(data)
  }

  // MARK: Private

  private func deleteTodoItem(uid: String, categoryId: String, todoId: String) async throws {
    try await Firestore.firestore()
      .collection("users")
      .document(uid)
      .collection("category_list")
      .document(categoryId)
      .collection("todo_list")
      .document(todoId)
      .delete()
  }
}
