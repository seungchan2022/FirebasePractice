import Foundation

public protocol GroupListUseCase: Sendable {
  var createGroup: (String) async throws -> GroupListEntity.Group.Item { get }

  var getGroupList: () async throws -> [GroupListEntity.Group.Item] { get }

  var getUserList: (Int, UserEntity.User.Response?) async throws -> [UserEntity.User.Response] { get }

  /// groupName, 현재 유저 uid + 선택한 유저들 uid
  var createNewGroup: (String, [UserEntity.User.Response]) async throws -> Bool { get }

  /// 추가할 카테고리를 선택하기 위해
  var getCategoryItemList: (String) async throws -> [TodoListEntity.Category.Item] { get }

  /// 그룹에 카테고리들 추가
  var addCategoryItemList: (String, [String]) async throws -> Bool { get }

  var getTodoItemList: (String) async throws -> [String: [TodoListEntity.TodoItem.Item]] { get }
}
