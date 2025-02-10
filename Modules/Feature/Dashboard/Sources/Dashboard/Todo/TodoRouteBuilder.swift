import Architecture
import Domain
import LinkNavigator

struct TodoRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.todo.rawValue

    return .init(matchPath: matchPath) { navigator, items, diContainer -> RouteViewController? in
      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }
      guard let item: TodoListEntity.TodoItem.Item = items.decoded() else { return .none }

      return WrappingController(matchPath: matchPath) {
        TodoPage(
          store: .init(
            initialState: TodoReducer.State(todoItem: item),
            reducer: {
              TodoReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
