import Foundation

public protocol UserUseCase: Sendable {
  var getUser: (String) async throws -> UserEntity.User.Response { get }

  var updateUserStatus: (String, Bool) async throws -> UserEntity.User.Response { get }

  var addWishItem: (String, String) async throws -> UserEntity.User.Response { get }

  var removeWishItem: (String, String) async throws -> UserEntity.User.Response { get }
}
