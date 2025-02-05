import Architecture
import LinkNavigator

struct TodoListRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.todoList.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in
      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }

      return WrappingController(matchPath: matchPath) {
        TodoListPage(
          store: .init(
            initialState: TodoListReducer.State(),
            reducer: {
              TodoListReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
