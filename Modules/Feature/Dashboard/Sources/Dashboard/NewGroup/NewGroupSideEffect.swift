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

  var routeToClose: () -> Void {
    {
      navigator.close(isAnimated: true, completeAction: { })
    }
  }
}
