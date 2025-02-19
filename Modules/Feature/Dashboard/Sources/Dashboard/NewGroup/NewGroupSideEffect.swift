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
  var getUserList: () -> Effect<NewGroupReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroup.groupListUseCase.getUserList()
          await send(NewGroupReducer.Action.fetchUserList(.success(response)))
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
