import Architecture
import Domain
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

// MARK: - UserUseCasePlatform

public struct UserUseCasePlatform {
  public init() { }
}

// MARK: UserUseCase

extension UserUseCasePlatform: UserUseCase {
  public var getUser: (String) async throws -> UserEntity.User.Response {
    { uid in
      do {
        return try await getDBUser(uid: uid)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var updateUserStatus: (UserEntity.User.Response) async throws -> UserEntity.User.Response {
    { user in
      let currentValue = user.isPremium ?? false
      let updateUser = UserEntity.User.Response(
        uid: user.uid,
        email: user.email,
        userName: user.userName,
        photoURL: user.photoURL,
        created: user.created,
        isPremium: !currentValue)
      do {
        try await updateStatus(uid: updateUser.uid, isPremium: !currentValue)
        return updateUser

      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

}

extension UserUseCasePlatform {

  func getDBUser(uid: String) async throws -> UserEntity.User.Response {
    try await Firestore.firestore().collection("users").document(uid).getDocument(as: UserEntity.User.Response.self)
  }

  func updateStatus(uid: String, isPremium: Bool) async throws {
    let data: [String: Any] = [
      "is_premium" : isPremium,
    ]

    try await Firestore.firestore().collection("users").document(uid).updateData(data)
  }

}
