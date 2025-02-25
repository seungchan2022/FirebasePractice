import Architecture
import Domain
import LinkNavigator

struct SelectCategoryRouteBuilder<RootNavigator: RootNavigatorType> {
  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.selectCategory.rawValue

    return .init(matchPath: matchPath) { navigator, items, diContainer -> RouteViewController? in
      guard let env: DashboardSidEffect = diContainer.resolve() else { return .none }
      guard let item: GroupListEntity.Group.Item = items.decoded() else { return .none }

      return WrappingController(matchPath: matchPath) {
        SelectCategoryPage(
          store: .init(
            initialState: SelectCategoryReducer.State(groupItem: item),
            reducer: {
              SelectCategoryReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
