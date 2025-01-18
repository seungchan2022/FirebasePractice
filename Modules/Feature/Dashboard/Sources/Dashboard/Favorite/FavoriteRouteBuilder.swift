import Architecture
import LinkNavigator

struct FavoriteRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.favorite.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in
      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }

      return WrappingController(matchPath: matchPath) {
        FavoritePage(
          store: .init(
            initialState: FavoriteReducer.State(),
            reducer: {
              FavoriteReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
