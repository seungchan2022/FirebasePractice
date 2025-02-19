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
        // 에러가 발생했을 경우 처리
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var getUserList: () async throws -> [UserEntity.User.Response] {
    {
      do {
        guard let me = Auth.auth().currentUser else {
          throw CompositeErrorRepository.incorrectUser
        }

        // Firestore에서 모든 유저 문서 가져오기
        let snapshot = try await Firestore.firestore().collection("users").getDocuments()

        // 문서들을 Authentication.Me.Response로 변환
        let itemList: [UserEntity.User.Response] = snapshot.documents.compactMap { document in
          try? document.data(as: UserEntity.User.Response.self)
        }

        // 현재 로그인한 유저는 제외
        let filteredItemList = itemList.filter { $0.uid != me.uid }

        return filteredItemList
      } catch {
        // 에러 발생 시 처리
        throw CompositeErrorRepository.other(error)
      }
    }
  }

}

extension GroupListUseCasePlatform {
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
}
