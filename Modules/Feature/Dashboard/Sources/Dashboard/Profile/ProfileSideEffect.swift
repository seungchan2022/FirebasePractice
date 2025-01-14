import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - ProfileSideEffect

struct ProfileSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension ProfileSideEffect {
  var getUser: () -> Effect<ProfileReducer.Action> {
    {
      .run { send in
        do {
          let response = try useCaseGroup.authUseCase.me()
          await send(ProfileReducer.Action.fetchUser(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchUser(.failure(.other(error))))
        }
      }
    }
  }

  var getDBUser: () -> Effect<ProfileReducer.Action> {
    {
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.userUseCase.getUser(user.uid)
          await send(ProfileReducer.Action.fetchDBUser(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchDBUser(.failure(.other(error))))
        }
      }
    }
  }

  var signOut: () -> Effect<ProfileReducer.Action> {
    {
      .run { send in
        do {
          let response = try useCaseGroup.authUseCase.signOut()
          await send(ProfileReducer.Action.fetchSignOut(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchSignOut(.failure(.other(error))))
        }
      }
    }
  }

  var updatePassword: (String, String) -> Effect<ProfileReducer.Action> {
    { currPassword, newPassword in
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.updatePassword(currPassword, newPassword)
          await send(ProfileReducer.Action.fetchUpdatePassword(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchUpdatePassword(.failure(.other(error))))
        }
      }
    }
  }

  var deleteUser: (String) -> Effect<ProfileReducer.Action> {
    { currPassword in
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.deleteUser(currPassword)
          await send(ProfileReducer.Action.fetchDeleteUser(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchDeleteUser(.failure(.other(error))))
        }
      }
    }
  }

  var deleteKakaoUser: () -> Effect<ProfileReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.deleteKakaoUser()
          await send(ProfileReducer.Action.fetchDeleteKakaoUser(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchDeleteKakaoUser(.failure(.other(error))))
        }
      }
    }
  }

  var deleteGoogleUser: () -> Effect<ProfileReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.deleteGoogleUser()
          await send(ProfileReducer.Action.fetchDeleteGoogleUser(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchDeleteGoogleUser(.failure(.other(error))))
        }
      }
    }
  }

  var deleteAppleUser: () -> Effect<ProfileReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.deleteAppleUser()
          await send(ProfileReducer.Action.fetchDeleteAppleUser(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchDeleteAppleUser(.failure(.other(error))))
        }
      }
    }
  }

  var getProvider: () -> Effect<ProfileReducer.Action> {
    {
      .run { send in
        do {
          let response = try useCaseGroup.authUseCase.getProvider()
          await send(ProfileReducer.Action.fetchProvider(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchProvider(.failure(.other(error))))
        }
      }
    }
  }

  var updateStatus: () -> Effect<ProfileReducer.Action> {
    {
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let dbUser = try await useCaseGroup.userUseCase.getUser(user.uid)
          let currentValue = dbUser.isPremium ?? false
          let response = try await useCaseGroup.userUseCase.updateUserStatus(dbUser.uid, !currentValue)
          await send(ProfileReducer.Action.fetchUpdateStatus(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchUpdateStatus(.failure(.other(error))))
        }
      }
    }
  }

  var addWishItem: (String) -> Effect<ProfileReducer.Action> {
    { item in
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.userUseCase.addWishItem(user.uid, item)
          await send(ProfileReducer.Action.fetchWishItem(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchWishItem(.failure(.other(error))))
        }
      }
    }
  }

  var removeWishItem: (String) -> Effect<ProfileReducer.Action> {
    { item in
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.userUseCase.removeWishItem(user.uid, item)
          await send(ProfileReducer.Action.fetchRemoveItem(.success(response)))

        } catch {
          await send(ProfileReducer.Action.fetchRemoveItem(.failure(.other(error))))
        }
      }
    }
  }

  var addMovieItem: () -> Effect<ProfileReducer.Action> {
    {
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let item = UserEntity.Movie.Item(id: "1", title: "joker", isPopular: true)
          let response = try await useCaseGroup.userUseCase.addMovie(user.uid, item)
          await send(ProfileReducer.Action.fetchAddMovieItem(.success(response)))
        } catch {
          await send(ProfileReducer.Action.fetchAddMovieItem(.failure(.other(error))))
        }
      }
    }
  }

  var removeMovieItem: () -> Effect<ProfileReducer.Action> {
    {
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.userUseCase.removeMovieItem(user.uid)

          await send(ProfileReducer.Action.fetchRemoveItem(.success(response)))

        } catch {
          await send(ProfileReducer.Action.fetchRemoveItem(.failure(.other(error))))
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
