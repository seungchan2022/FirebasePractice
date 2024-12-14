import Architecture
import Dashboard
import LinkNavigator

struct AppRouterBuilderGroup<RootNavigator: RootNavigatorType> {
  @MainActor
  public func applicationBuilders() -> [RouteBuilderOf<RootNavigator>] {
    DashboardRouteBuilderGroup().release()
  }
}
