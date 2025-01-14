import Foundation
@preconcurrency import LinkNavigator
import Architecture
import Platform

@MainActor
final class AppContainer {

  // MARK: Lifecycle

  // MARK: Internal

  let dependency: AppSideEffect
  let linkNavigayor: TabLinkNavigator

  init(dependency: AppSideEffect,
       linkNavigayor: TabLinkNavigator) {
    self.dependency = dependency
    self.linkNavigayor = linkNavigayor
  }
}

extension AppContainer {
  class func build() -> AppContainer {
    let sideEffect = AppSideEffect(
      toastViewModel: ToastViewModel(),
      authUseCase: AuthUseCasePlatform(),
      userUseCase: UserUseCasePlatform(),
      productUseCase: ProductUseCasePlatform())

    return .init(
      dependency: sideEffect,
      linkNavigayor: .init(
        routeBuilderItemList: AppRouterBuilderGroup().applicationBuilders(),
        dependency: sideEffect))
  }
}
