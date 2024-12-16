import Foundation
@preconcurrency import LinkNavigator

@MainActor
final class AppContainer {

  // MARK: Lifecycle

  init(dependency: AppSideEffect = AppSideEffect.generate()) {
    self.dependency = dependency

    let builder = AppRouterBuilderGroup<SingleLinkNavigator>()
    linkNavigayor = .init(
      routeBuilderItemList: builder.applicationBuilders(),
      dependency: dependency)
  }

  // MARK: Internal

  let dependency: AppSideEffect
  let linkNavigayor: SingleLinkNavigator

}
