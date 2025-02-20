import Foundation

public protocol GroupListUseCase: Sendable {
  var createGroup: (String) async throws -> GroupListEntity.Group.Item { get }

  var getGroupList: () async throws -> [GroupListEntity.Group.Item] { get }

  var getUserList: (Int, UserEntity.User.Response?) async throws -> [UserEntity.User.Response] { get }

  /// groupName, 현재 유저 uid + 선택한 유저들 uid
  var createNewGroup: (String, [UserEntity.User.Response]) async throws -> Bool { get }
}
