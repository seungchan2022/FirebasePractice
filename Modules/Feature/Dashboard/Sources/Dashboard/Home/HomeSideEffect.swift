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
          let response = try await useCaseGroup.authUseCase.me()
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

  var updatePassword: (String, String) -> Effect<HomeReducer.Action> {
    { currPassword, newPassword in
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.updatePassword(currPassword, newPassword)
          await send(HomeReducer.Action.fetchUpdatePassword(.success(response)))
        } catch {
          await send(HomeReducer.Action.fetchUpdatePassword(.failure(.other(error))))
        }
      }
    }
  }

  var deleteUser: (String) -> Effect<HomeReducer.Action> {
    { currPassword in
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.deleteUser(currPassword)
          await send(HomeReducer.Action.fetchDeleteUser(.success(response)))
        } catch {
          await send(HomeReducer.Action.fetchDeleteUser(.failure(.other(error))))
        }
      }
    }
  }

  var deleteKakaoUser: () -> Effect<HomeReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.deleteKakaoUser()
          await send(HomeReducer.Action.fetchDeleteKakaoUser(.success(response)))
        } catch {
          await send(HomeReducer.Action.fetchDeleteKakaoUser(.failure(.other(error))))
        }
      }
    }
  }

  var deleteGoogleUser: () -> Effect<HomeReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.deleteGoogleUser()
          await send(HomeReducer.Action.fetchDeleteGoogleUser(.success(response)))
        } catch {
          await send(HomeReducer.Action.fetchDeleteGoogleUser(.failure(.other(error))))
        }
      }
    }
  }

  var deleteAppleUser: () -> Effect<HomeReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.deleteAppleUser()
          await send(HomeReducer.Action.fetchDeleteAppleUser(.success(response)))
        } catch {
          await send(HomeReducer.Action.fetchDeleteAppleUser(.failure(.other(error))))
        }
      }
    }
  }

  var getProvider: () -> Effect<HomeReducer.Action> {
    {
      .run { send in
        do {
          let response = try useCaseGroup.authUseCase.getProvider()
          await send(HomeReducer.Action.fetchProvider(.success(response)))
        } catch {
          await send(HomeReducer.Action.fetchProvider(.failure(.other(error))))
        }
      }
    }
  }

  var routeToSignIn: () -> Void {
    {
      navigator.replace(
        linkItem: .init(
          path: Link.Dashboard.Path.signIn.rawValue,
          items: .none),
        isAnimated: false)
    }
  }
}
