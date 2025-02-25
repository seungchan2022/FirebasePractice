import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - GroupListDetailSideEffect

struct GroupListDetailSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension GroupListDetailSideEffect {

  var getTodoItemList: (String) -> Effect<GroupListDetailReducer.Action> {
    { groudId in
      .run { send in
        do {
          let response = try await useCaseGroup.groupListUseCase.getTodoItemList(groudId)
          await send(GroupListDetailReducer.Action.fetchTodoItemList(.success(response)))
        } catch {
          await send(GroupListDetailReducer.Action.fetchTodoItemList(.failure(.other(error))))
        }
      }
    }
  }

  var routeToSelectCategory: (GroupListEntity.Group.Item) -> Void {
    { item in
      navigator.fullSheet(
        linkItem: .init(
          path: Link.Dashboard.Path.selectCategory.rawValue,
          items: item),
        isAnimated: true,
        prefersLargeTitles: false)
    }
  }
}
