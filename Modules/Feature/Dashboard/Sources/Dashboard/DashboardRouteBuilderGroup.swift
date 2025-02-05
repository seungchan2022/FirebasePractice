import Architecture
import LinkNavigator

// MARK: - DashboardRouteBuilderGroup

public struct DashboardRouteBuilderGroup<RootNavigator: RootNavigatorType> {
  public init() { }
}

extension DashboardRouteBuilderGroup {
  @MainActor
  public func release() -> [RouteBuilderOf<RootNavigator>] {
    [
      ProfileRouteBuilder.generate(),
      SignInRouteBuilder.generate(),
      SignUpRouteBuilder.generate(),
      ProductRouteBuilder.generate(),
      FavoriteRouteBuilder.generate(),
      TodoListRouteBuilder.generate(),
      TodoListDetailRouteBuilder.generate(),
    ]
  }
}
