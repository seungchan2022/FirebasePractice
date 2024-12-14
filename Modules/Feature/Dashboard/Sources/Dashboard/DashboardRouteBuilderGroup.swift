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
      SampleRouteBuilder.generate(),
      HomeRouteBuilder.generate(),
    ]
  }
}
