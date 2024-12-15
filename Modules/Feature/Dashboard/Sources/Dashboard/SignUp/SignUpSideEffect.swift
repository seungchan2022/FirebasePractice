import Architecture
import ComposableArchitecture
import Foundation
import LinkNavigator

// MARK: - SignUpSideEffect

struct SignUpSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension SignUpSideEffect {
  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }
}
