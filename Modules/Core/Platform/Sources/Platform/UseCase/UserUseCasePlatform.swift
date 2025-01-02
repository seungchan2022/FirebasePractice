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
}

extension UserUseCasePlatform {
  func getDBUser(uid: String) async throws -> UserEntity.User.Response {
    try await Firestore.firestore().collection("users").document(uid).getDocument(as: UserEntity.User.Response.self)
  }
}
