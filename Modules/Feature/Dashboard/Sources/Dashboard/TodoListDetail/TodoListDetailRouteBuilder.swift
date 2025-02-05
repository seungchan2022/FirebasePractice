import Architecture
import Domain
import LinkNavigator

struct TodoListDetailRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.todoListDetail.rawValue

    return .init(matchPath: matchPath) { navigator, items, diContainer -> RouteViewController? in
      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }
      guard let item: TodoListEntity.Category.Item = items.decoded() else { return .none }

      return WrappingController(matchPath: matchPath) {
        TodoListDetailPage(
          store: .init(
            initialState: TodoListDetailReducer.State(categoryItem: item),
            reducer: {
              TodoListDetailReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
