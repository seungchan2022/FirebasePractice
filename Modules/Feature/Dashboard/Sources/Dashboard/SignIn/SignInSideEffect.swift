import Architecture
import ComposableArchitecture
import Foundation
import LinkNavigator

// MARK: - SignInSideEffect

struct SignInSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension SignInSideEffect {
  var routeToSignUp: () -> Void {
    {
      navigator.next(
        linkItem: .init(
          path: Link.Dashboard.Path.signUp.rawValue,
          items: .none),
        isAnimated: true)
    }
  }
}
