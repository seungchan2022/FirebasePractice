import Architecture
import LinkNavigator

struct ProductRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.product.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in

      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }

      return WrappingController(matchPath: matchPath) {
        ProductPage(
          store: .init(
            initialState: ProductReducer.State(),
            reducer: {
              ProductReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
