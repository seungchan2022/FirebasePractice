import Architecture
import LinkNavigator

struct NewGroupRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.newGroup.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in
      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }

      return WrappingController(matchPath: matchPath) {
        NewGroupPage(
          store: .init(
            initialState: NewGroupReducer.State(),
            reducer: {
              NewGroupReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
