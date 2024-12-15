import Architecture
import LinkNavigator

struct SignInRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.signIn.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in

      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }

      return WrappingController(matchPath: matchPath) {
        SignInPage(
          store: .init(
            initialState: SignInReducer.State(),
            reducer: {
              SignInReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
