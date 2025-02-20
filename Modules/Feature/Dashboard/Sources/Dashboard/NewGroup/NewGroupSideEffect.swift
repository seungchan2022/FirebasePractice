import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - NewGroupSideEffect

struct NewGroupSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension NewGroupSideEffect {

  var getUserList: (Int, UserEntity.User.Response?) -> Effect<NewGroupReducer.Action> {
    { limit, item in
      .run { send in
        do {
          let itemList = try await useCaseGroup.groupListUseCase.getUserList(limit, item)
          await send(NewGroupReducer.Action.fetchUserList(.success(itemList)))
        } catch {
          await send(NewGroupReducer.Action.fetchUserList(.failure(.other(error))))
        }
      }
    }
  }

  var createNewGroup: (String, [UserEntity.User.Response]) -> Effect<NewGroupReducer.Action> {
    { groupName, memberList in
      .run { send in
        do {
          let response = try await useCaseGroup.groupListUseCase.createNewGroup(groupName, memberList)
          await send(NewGroupReducer.Action.fetchNewGroup(.success(response)))
        } catch {
          await send(NewGroupReducer.Action.fetchNewGroup(.failure(.other(error))))
        }
      }
    }
  }

  var routeToClose: () -> Void {
    {
      navigator.close(isAnimated: true, completeAction: { })
    }
  }
}
