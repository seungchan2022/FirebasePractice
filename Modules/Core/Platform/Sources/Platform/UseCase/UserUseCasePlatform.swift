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

  public var addWishItem: (String, String) async throws -> UserEntity.User.Response {
    { uid, item in
      do {
        try await addWishItem(uid: uid, item: item)
        return try await getDBUser(uid: uid)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var removeWishItem: (String, String) async throws -> UserEntity.User.Response {
    { uid, item in
      do {
        try await removeWishItem(uid: uid, item: item)
        return try await getDBUser(uid: uid)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var addMovie: (String, UserEntity.Movie.Item) async throws -> UserEntity.User.Response {
    { uid, item in
      do {
        try await addMovieItem(uid: uid, item: item)
        return try await getDBUser(uid: uid)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var removeMovieItem: (String) async throws -> UserEntity.User.Response {
    { uid in
      do {
        try await removeMovieItem(uid: uid)
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

  func addWishItem(uid: String, item: String) async throws {
    let data: [String: Any] = [
      "wish_list": FieldValue.arrayUnion([item]),
    ]

    try await Firestore.firestore().collection("users").document(uid).updateData(data)
  }

  func removeWishItem(uid: String, item: String) async throws {
    let data: [String: Any] = [
      "wish_list": FieldValue.arrayRemove([item]),
    ]

    try await Firestore.firestore().collection("users").document(uid).updateData(data)
  }

  func addMovieItem(uid: String, item: UserEntity.Movie.Item) async throws {
    let encoder = Firestore.Encoder()

    guard let data = try? encoder.encode(item) else { throw CompositeErrorRepository.invalidTypeCasting }

    let dict: [String: Any] = [
      "movie": data,
    ]

    try await Firestore.firestore().collection("users").document(uid).updateData(dict)
  }

  func removeMovieItem(uid: String) async throws {
    let data: [String: Any?] = [
      "movie": .none,
    ]

    try await Firestore.firestore().collection("users").document(uid).updateData(data as [AnyHashable: Any])
  }

}
