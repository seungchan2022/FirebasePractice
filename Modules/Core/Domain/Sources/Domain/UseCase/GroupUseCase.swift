import Foundation

public protocol GroupUseCase: Sendable {
  var createGroup: (String) async throws -> GroupEntity.Group.Item { get }
}
