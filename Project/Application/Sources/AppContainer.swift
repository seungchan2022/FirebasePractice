import Architecture
import Foundation
@preconcurrency import LinkNavigator
import Platform

// MARK: - AppContainer

@MainActor
final class AppContainer {

  // MARK: Lifecycle

  init(
    dependency: AppSideEffect,
    linkNavigayor: TabLinkNavigator)
  {
    self.dependency = dependency
    self.linkNavigayor = linkNavigayor
  }

  // MARK: Internal

  let dependency: AppSideEffect
  let linkNavigayor: TabLinkNavigator

}

extension AppContainer {
  class func build() -> AppContainer {
    let sideEffect = AppSideEffect(
      toastViewModel: ToastViewModel(),
      authUseCase: AuthUseCasePlatform(),
      userUseCase: UserUseCasePlatform(),
      productUseCase: ProductUseCasePlatform(),
      todoListUseCase: TodoListUseCasePlatform())

    return .init(
      dependency: sideEffect,
      linkNavigayor: .init(
        routeBuilderItemList: AppRouterBuilderGroup().applicationBuilders(),
        dependency: sideEffect))
  }
}
