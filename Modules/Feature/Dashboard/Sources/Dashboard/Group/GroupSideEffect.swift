import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - GroupSideEffect

struct GroupSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension GroupSideEffect {
  var createGroup: (String) -> Effect<GroupReducer.Action> {
    { groupName in
      .run { send in
        do {
          let response = try await useCaseGroup.groupUseCase.createGroup(groupName)
          await send(GroupReducer.Action.fetchCreateGroup(.success(response)))
        } catch {
          await send(GroupReducer.Action.fetchCreateGroup(.failure(.other(error))))
        }
      }
    }
  }
}
