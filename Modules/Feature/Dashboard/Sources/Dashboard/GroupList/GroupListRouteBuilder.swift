import Architecture
import LinkNavigator

struct GroupListRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.groupList.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in
      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }

      return WrappingController(matchPath: matchPath) {
        GroupListPage(
          store: .init(
            initialState: GroupListReducer.State(),
            reducer: {
              GroupListReducer(
                sideEffect: .init(
                  useCaseGroupList: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
