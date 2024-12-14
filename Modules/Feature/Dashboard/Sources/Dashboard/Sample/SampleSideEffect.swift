import Architecture
import Domain
import Foundation
import LinkNavigator

// MARK: - SampleSideEffect

struct SampleSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension SampleSideEffect {

  var routeToNext: () -> Void {
    {
      navigator.next(
        linkItem: LinkItem(
          path: Link.Dashboard.Path.home.rawValue,
          items: .none),
        isAnimated: true)
    }
  }
}
