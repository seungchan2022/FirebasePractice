import Architecture
import Domain
import LinkNavigator

struct TodoDetailRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.todoDetail.rawValue

    return .init(matchPath: matchPath) { navigator, items, diContainer -> RouteViewController? in
      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }
      guard let item: TodoListEntity.Category.Item = items.decoded() else { return .none }

      return WrappingController(matchPath: matchPath) {
        TodoDetailPage(
          store: .init(
            initialState: TodoDetailReducer.State(categoryItem: item),
            reducer: {
              TodoDetailReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
