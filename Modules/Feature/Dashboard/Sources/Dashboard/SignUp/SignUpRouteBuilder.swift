import Architecture
import LinkNavigator

struct SignUpRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.signUp.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in

      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }

      return WrappingController(matchPath: matchPath) {
        SignUpPage(
          store: .init(
            initialState: SignUpReducer.State(),
            reducer: {
              SignUpReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
