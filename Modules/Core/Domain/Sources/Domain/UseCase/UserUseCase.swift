import Foundation

public protocol UserUseCase: Sendable {
  var getUser: (String) async throws -> UserEntity.User.Response { get }
  var updateUserStatus: (UserEntity.User.Response) async throws -> UserEntity.User.Response { get }
}
