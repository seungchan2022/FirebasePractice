import Architecture
import Domain
import Foundation
import LinkNavigator

// MARK: - HomeSideEffect

struct HomeSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension HomeSideEffect {
  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }

}
