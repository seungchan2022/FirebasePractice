import Architecture
import Domain
import LinkNavigator

struct GroupListDetailRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.groupListDetail.rawValue

    return .init(matchPath: matchPath) { navigator, items, diContainer -> RouteViewController? in
      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }

      guard let item: GroupListEntity.Group.Item = items.decoded() else { return .none }

      return WrappingController(matchPath: matchPath) {
        GroupListDetailPage(
          store: .init(
            initialState: GroupListDetailReducer.State(groupItem: item),
            reducer: {
              GroupListDetailReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
