import Architecture
import Combine
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

  /// 여기에 productId는 Product아이템의 ID이고 remove에서는 favoriteList에서 자동 생성된 id?
  public var addFavoriteProduct: (Int) async throws -> Bool {
    { productId in
      guard let me = Auth.auth().currentUser else { return false }
      let document = Firestore.firestore().collection("users")
        .document(me.uid)
        .collection("favorite_list")
        .document()

      let documentId = document.documentID

      let data: [String: Any] = [
        "id": documentId,
        "product_id": productId,
        "date_created": Date(),
      ]

      do {
        try await document.setData(data, merge: false)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var getFavoriteProduct: () async throws -> [UserEntity.Favorite.Item] {
    {
      guard let me = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }
      let ref = Firestore.firestore().collection("users")
        .document(me.uid)
        .collection("favorite_list")

      do {
        return try await ref.getDocuments(as: UserEntity.Favorite.Item.self)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var addListenerForAllUserFavoriteProducts: () -> AnyPublisher<[UserEntity.Favorite.Item], CompositeErrorRepository> {
    {
      let publisher = PassthroughSubject<[UserEntity.Favorite.Item], CompositeErrorRepository>()

      guard let me = Auth.auth().currentUser
      else { return Fail(error: CompositeErrorRepository.incorrectUser).eraseToAnyPublisher() }

      let query = Firestore.firestore()
        .collection("users")
        .document(me.uid)
        .collection("favorite_list")

      query.addSnapshotListener { querySnapshot, _ in
        guard let documents = querySnapshot?.documents else {
          publisher.send(completion: .failure(.invalidTypeCasting))
          return
        }

        let products = documents.compactMap { try? $0.data(as: UserEntity.Favorite.Item.self) }

        publisher.send(products)
      }

      return publisher.eraseToAnyPublisher()
    }
  }

  public var removeFavoriteProduct: (String) async throws -> Bool {
    { favoriteProductId in

      guard let me = Auth.auth().currentUser else { return false }

      let document = Firestore.firestore().collection("users")
        .document(me.uid)
        .collection("favorite_list")
        .document(favoriteProductId)

      do {
        try await document.delete()
        return true
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

extension Query {
  func addSnapshotListener<T>(as _: T.Type) -> AnyPublisher<[T], CompositeErrorRepository> where T: Decodable {
    let subject = PassthroughSubject<[T], CompositeErrorRepository>()

    addSnapshotListener { snapshot, error in
      if let error {
        subject.send(completion: .failure(.other(error)))
        return
      }

      let documents = snapshot?.documents ?? []
      let itemList = documents.compactMap { try? $0.data(as: T.self) }

      subject.send(itemList)
    }

    return subject.eraseToAnyPublisher()
  }
}
