import Domain
import FirebaseAuth
import FirebaseFirestore
import Foundation

// MARK: - GroupListUseCasePlatform

public struct GroupListUseCasePlatform {
  public init() { }
}

// MARK: GroupListUseCase

extension GroupListUseCasePlatform: GroupListUseCase {

  public var createGroup: (String) async throws -> GroupListEntity.Group.Item {
    { groupName in
      guard let me = Auth.auth().currentUser else {
        throw CompositeErrorRepository.incorrectUser
      }

      // Firestore에서 새 그룹 문서 생성 및 ID 가져오기
      let document = Firestore.firestore()
        .collection("groups")
        .document()

      let documentId = document.documentID

      let item = GroupListEntity.Group.Item(
        id: documentId, // Firestore에서 생성한 documentID 사용
        name: groupName,
        memberList: [me.uid])

      do {
        try await addGroupId(groupId: item.id)
        try await createGroup(item: item)
        return item
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var getGroupList: () async throws -> [GroupListEntity.Group.Item] {
    {
      do {
        guard let me = Auth.auth().currentUser else {
          throw CompositeErrorRepository.incorrectUser
        }

        // 1️⃣ 현재 로그인된 사용자의 group_list 가져오기
        let userDoc = try await Firestore.firestore()
          .collection("users")
          .document(me.uid)
          .getDocument()

        guard let groupIds = userDoc.data()?["group_list"] as? [String], !groupIds.isEmpty else {
          return [] // 그룹이 없으면 빈 배열 반환
        }

        // 2️⃣ group_list에 있는 그룹 ID들을 이용해서 그룹 정보 가져오기
        let groupDocuments = try await Firestore.firestore()
          .collection("groups")
          .whereField(FieldPath.documentID(), in: groupIds)
          .getDocuments()

        // 3️⃣ GroupListEntity.Group.Item으로 변환
        let groupList = try groupDocuments.documents.map { doc in
          try doc.data(as: GroupListEntity.Group.Item.self)
        }

        return groupList
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var getUserList: (Int, UserEntity.User.Response?) async throws -> [UserEntity.User.Response] {
    { limit, item in
      do {
        guard let me = Auth.auth().currentUser else {
          throw CompositeErrorRepository.incorrectUser
        }

        // 현재 로그인한 유저 제외
        let itemList = try await getAllUser(limit: limit, lastItem: item).filter { $0.uid != me.uid }

        return itemList
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  /// 새로운 그룹 생성 및 멤버 추가
  public var createNewGroup: (String, [UserEntity.User.Response]) async throws -> Bool {
    { groupName, memberList in
      guard let me = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }

      let document = Firestore.firestore()
        .collection("groups")
        .document()

      let documentId = document.documentID

      let item = GroupListEntity.Group.Item(
        id: documentId,
        name: groupName,
        memberList: [me.uid] + memberList.map { $0.uid })

      do {
        try await addGroupId(groupId: item.id, forUsers: [me.serialized()] + memberList)
        try await createGroup(item: item)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  /// 카테고리를 추가하기 위해 현재 로그인된 유저의 모든 카테고리 불러오기
  public var getCategoryItemList: (String) async throws -> [TodoListEntity.Category.Item] {
    { uid in
      do {
        return try await Firestore.firestore()
          .collection("users")
          .document(uid)
          .collection("category_list")
          .order(by: "date_created", descending: false)
          .getDocuments(as: TodoListEntity.Category.Item.self)

      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  /// 그룹에 카테고리 여러 개 추가
  public var addCategoryItemList: (String, [String]) async throws -> Bool {
    { groupId, categoryIdList in
      let data: [String: Any] = [
        "category_list": FieldValue.arrayUnion(categoryIdList),
      ]
      do {
        try await Firestore.firestore()
          .collection("groups")
          .document(groupId)
          .updateData(data)

        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  /// 공유된 카테고리의 투두 가져오기
  public var getTodoItemList: (String) async throws -> [String: [TodoListEntity.TodoItem.Item]] {
    { groupId in

      let groupDoc = try await Firestore.firestore()
        .collection("groups")
        .document(groupId)
        .getDocument()

      // 그룹에서 공유된 카테고리 목록 가져오기
      guard let categoryIds = groupDoc.data()?["category_list"] as? [String], !categoryIds.isEmpty else {
        return [:] // 카테고리가 없으면 빈 딕셔너리 반환
      }

      // Firestore에서 모든 유저의 해당 카테고리에 있는 todo 가져오기
      let snapshot = try await Firestore.firestore()
        .collectionGroup("todo_list")
        .whereField("category_id", in: categoryIds)
        .getDocuments()

      do {
        // 데이터를 카테고리별로 그룹화
        let todosByCategory = try snapshot.documents.reduce(into: [String: [TodoListEntity.TodoItem.Item]]()) { result, doc in
          let todoItem = try doc.data(as: TodoListEntity.TodoItem.Item.self)
          let categoryId = todoItem.categoryId

          // 카테고리별로 데이터를 덧셈 연산자 사용하여 처리
          result[categoryId] = (result[categoryId] ?? []) + [todoItem]
        }

        return todosByCategory
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }
}

extension GroupListUseCasePlatform {

  // MARK: Internal

  func addGroupId(groupId: String) async throws {
    guard let me = Auth.auth().currentUser else { return }

    let data: [String: Any] = [
      "group_list": FieldValue.arrayUnion([groupId]),
    ]

    try await Firestore.firestore()
      .collection("users")
      .document(me.uid)
      .updateData(data)
  }

  /// 모든 유저의 group_list에 groupId를 추가
  func addGroupId(groupId: String, forUsers users: [UserEntity.User.Response]) async throws {
    for user in users {
      let data: [String: Any] = [
        "group_list": FieldValue.arrayUnion([groupId]),
      ]

      // 각 유저의 Firestore에 group_list 업데이트
      try await Firestore.firestore()
        .collection("users")
        .document(user.uid)
        .updateData(data)
    }
  }

  func removeGroupId(groupId: String) async throws {
    guard let me = Auth.auth().currentUser else { return }

    let data: [String: Any] = [
      "group_list": FieldValue.arrayRemove([groupId]),
    ]

    try await Firestore.firestore()
      .collection("users")
      .document(me.uid)
      .updateData(data)
  }

  func createGroup(item: GroupListEntity.Group.Item) async throws {
    try Firestore.firestore()
      .collection("groups")
      .document(item.id)
      .setData(from: item.self, merge: true)
  }

  // MARK: Private

  private func getAllUser(limit: Int, lastItem: UserEntity.User.Response?) async throws -> [UserEntity.User.Response] {
    let query = Firestore.firestore()
      .collection("users")
      .order(by: "created")
      .limit(to: limit)

    if let lastItem {
      return try await query
        .start(after: [lastItem.created ?? .now])
        .getDocuments(as: UserEntity.User.Response.self)
    } else {
      return try await query.getDocuments(as: UserEntity.User.Response.self)
    }
  }

}

extension FirebaseAuth.User {
  fileprivate func serialized() -> UserEntity.User.Response {
    .init(uid: uid, email: email, userName: displayName, photoURL: photoURL?.absoluteString, created: Date())
  }
}
