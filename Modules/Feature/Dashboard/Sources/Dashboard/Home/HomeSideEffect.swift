import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - HomeSideEffect

struct HomeSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension HomeSideEffect {
  var getUser: () -> Effect<HomeReducer.Action> {
    {
      .run { send in
        do {
          let response = try useCaseGroup.authUseCase.me()
          await send(HomeReducer.Action.fetchUser(.success(response)))
        } catch {
          await send(HomeReducer.Action.fetchUser(.failure(.other(error))))
        }
      }
    }
  }

  var signOut: () -> Effect<HomeReducer.Action> {
    {
      .run { send in
        do {
          let response = try useCaseGroup.authUseCase.signOut()
          await send(HomeReducer.Action.fetchSignOut(.success(response)))
        } catch {
          await send(HomeReducer.Action.fetchSignOut(.failure(.other(error))))
        }
      }
    }
  }

  var routeSignIn: () -> Void {
    {
      navigator.replace(
        linkItem: .init(
          path: Link.Dashboard.Path.signIn.rawValue,
          items: .none),
        isAnimated: false)
    }
  }
}
