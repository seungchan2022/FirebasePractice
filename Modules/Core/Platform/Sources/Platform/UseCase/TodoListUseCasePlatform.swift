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

  public var addCategoryItem: (String, String) async throws -> TodoListEntity.Category.Item {
    { uid, categoryName in
      do {
        let docRef = Firestore.firestore()
          .collection("users")
          .document(uid)
          .collection("category_list")
          .document()

        let newItem = TodoListEntity.Category.Item(
          id: docRef.documentID,
          title: categoryName)

        try docRef.setData(from: newItem, merge: true)

        return newItem
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

  public var addTodoItem: (String, String, String) async throws -> TodoListEntity.TodoItem.Item {
    { uid, categoryId, itemName in
      do {
        let docRef = Firestore.firestore()
          .collection("users")
          .document(uid)
          .collection("category_list")
          .document(categoryId)
          .collection("todo_list")
          .document()

        let newItem = TodoListEntity.TodoItem.Item(
          id: docRef.documentID,
          categoryId: categoryId,
          title: itemName)

        try docRef.setData(from: newItem, merge: true)

        return newItem
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

  public var updateTodoItemStatus: (TodoListEntity.TodoItem.Item, Bool) async throws -> TodoListEntity.TodoItem.Item {
    { item, isCompleted in

      guard let me = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }

      do {
        try await updateTodoItemStatus(uid: me.uid, categoryId: item.categoryId, todoId: item.id, isCompleted: isCompleted)
        return try await getTodoItem(me.uid, item.categoryId, item.id)

      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var updateMemo: (TodoListEntity.TodoItem.Item, String) async throws -> TodoListEntity.TodoItem.Item {
    { item, memoText in

      guard let me = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }
      do {
        try await updateMemo(uid: me.uid, categoryId: item.categoryId, todoId: item.id, memoText: memoText)
        return try await getTodoItem(me.uid, item.categoryId, item.id)
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

  public var editTodoItemTitle: (TodoListEntity.TodoItem.Item, String) async throws -> TodoListEntity.TodoItem.Item {
    { item, newTitle in
      guard let me = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }

      do {
        try await editTodoItemTitle(uid: me.uid, categoryId: item.categoryId, todoId: item.id, newTitle: newTitle)
        return try await getTodoItem(me.uid, item.categoryId, item.id)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var deleteCategoryItem: (TodoListEntity.Category.Item) async throws -> Bool {
    { item in
      guard let me = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }

      do {
        try await deleteCategoryItem(uid: me.uid, categoryId: item.id)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var editCategoryItemTitle: (TodoListEntity.Category.Item, String) async throws -> TodoListEntity.Category.Item {
    { item, newTitle in
      guard let me = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }

      do {
        try await editCategoryItemTitle(uid: me.uid, categoryId: item.id, newTitle: newTitle)
        return try await getCategoryItem(me.uid, item.id)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

}

extension TodoListUseCasePlatform {
  private func updateTodoItemStatus(uid: String, categoryId: String, todoId: String, isCompleted: Bool) async throws {
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

  private func updateMemo(uid: String, categoryId: String, todoId: String, memoText: String) async throws {
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

  private func editTodoItemTitle(uid: String, categoryId: String, todoId: String, newTitle: String) async throws {
    let data: [String: Any] = [
      "title" : newTitle,
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

  private func deleteCategoryItem(uid: String, categoryId: String) async throws {
    let db = Firestore.firestore()

    let todoListRef = db
      .collection("users")
      .document(uid)
      .collection("category_list")
      .document(categoryId)
      .collection("todo_list")

    let categoryItemRef = db
      .collection("users")
      .document(uid)
      .collection("category_list")
      .document(categoryId)

    do {
      let snapshot = try await todoListRef.getDocuments()
      let batch = db.batch()

      for document in snapshot.documents {
        batch.deleteDocument(document.reference)
      }

      batch.deleteDocument(categoryItemRef)

      try await batch.commit()
    } catch {
      throw CompositeErrorRepository.other(error)
    }
  }

  private func editCategoryItemTitle(uid: String, categoryId: String, newTitle: String) async throws {
    let data: [String: Any] = [
      "title" : newTitle,
    ]

    try await Firestore.firestore()
      .collection("users")
      .document(uid)
      .collection("category_list")
      .document(categoryId)
      .updateData(data)
  }

}
