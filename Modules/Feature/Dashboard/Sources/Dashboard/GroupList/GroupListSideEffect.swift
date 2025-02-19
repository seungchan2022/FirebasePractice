import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - GroupListSideEffect

struct GroupListSideEffect {
  let useCaseGroupList: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension GroupListSideEffect {
  var createGroup: (String) -> Effect<GroupListReducer.Action> {
    { groupName in
      .run { send in
        do {
          let response = try await useCaseGroupList.groupListUseCase.createGroup(groupName)
          await send(GroupListReducer.Action.fetchCreateGroup(.success(response)))
        } catch {
          await send(GroupListReducer.Action.fetchCreateGroup(.failure(.other(error))))
        }
      }
    }
  }

  var getGroupList: () -> Effect<GroupListReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroupList.groupListUseCase.getGroupList()
          await send(GroupListReducer.Action.fetchGroupList(.success(response)))
        } catch {
          await send(GroupListReducer.Action.fetchGroupList(.failure(.other(error))))
        }
      }
    }
  }

  var routeToNewGroup: () -> Void {
    {
      navigator.fullSheet(
        linkItem: .init(
          path: Link.Dashboard.Path.newGroup.rawValue,
          items: .none),
        isAnimated: true,
        prefersLargeTitles: true)
    }
  }
}
