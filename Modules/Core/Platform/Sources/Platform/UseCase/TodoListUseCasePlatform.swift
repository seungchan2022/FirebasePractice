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
        let snapshot = try await Firestore.firestore().collection("users")
          .document(uid)
          .collection("category_list")
          .order(by: "date_created", descending: false)
          .getDocuments()

        return try snapshot.documents.compactMap { doc in
          try doc.data(as: TodoListEntity.Category.Item.self)
        }
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

}

extension TodoListUseCasePlatform {
  func addCategoryItem(uid: String, item: TodoListEntity.Category.Item) async throws {
    let docRef = Firestore.firestore().collection("users")
      .document(uid)
      .collection("category_list")
      .document(item.id)

    try docRef.setData(from: item, merge: true)
  }
}
