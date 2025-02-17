import Domain
import FirebaseAuth
import FirebaseFirestore
import Foundation

// MARK: - GroupUseCasePlatform

public struct GroupUseCasePlatform {
  public init() { }
}

// MARK: GroupUseCase

extension GroupUseCasePlatform: GroupUseCase {

  public var createGroup: (String) async throws -> GroupEntity.Group.Item {
    { groupName in
      guard let me = Auth.auth().currentUser else {
        throw CompositeErrorRepository.incorrectUser
      }

      let item = GroupEntity.Group.Item(
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
}

extension GroupUseCasePlatform {
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

  func createGroup(item: GroupEntity.Group.Item) async throws {
    try Firestore.firestore()
      .collection("groups")
      .document(item.id)
      .setData(from: item.self, merge: true)
  }
}
