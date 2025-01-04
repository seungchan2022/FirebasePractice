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

  public var updateUserStatus: (String, Bool) async throws -> UserEntity.User.Response {
    { uid, isPremium in
      do {
        try await updateStatus(uid: uid, isPremium: isPremium)
        return try await getDBUser(uid: uid)
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
