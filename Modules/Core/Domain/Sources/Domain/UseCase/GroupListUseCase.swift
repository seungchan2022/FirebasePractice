import Foundation

public protocol GroupListUseCase: Sendable {
  var createGroup: (String) async throws -> GroupListEntity.Group.Item { get }

  var getGroupList: () async throws -> [GroupListEntity.Group.Item] { get }

  var getUserList: (Int, UserEntity.User.Response?) async throws -> [UserEntity.User.Response] { get }
}
