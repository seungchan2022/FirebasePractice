import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - SignInSideEffect

struct SignInSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension SignInSideEffect {
  var signInEmail: (AuthEntity.Email.Request) -> Effect<SignInReducer.Action> {
    { req in
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.signInEmail(req)
          await send(SignInReducer.Action.fetchSignIn(.success(response)))

        } catch {
          await send(SignInReducer.Action.fetchSignIn(.failure(.other(error))))
        }
      }
    }
  }

  var resetPassword: (String) -> Effect<SignInReducer.Action> {
    { email in
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.resetPassword(email)
          await send(SignInReducer.Action.fetchResetPassword(.success(response)))
        } catch {
          await send(SignInReducer.Action.fetchResetPassword(.failure(.other(error))))
        }
      }
    }
  }

  var googleSignIn: () -> Effect<SignInReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.signInGoogle()
          await send(SignInReducer.Action.fetchSignInGoogle(.success(response)))
        } catch {
          await send(SignInReducer.Action.fetchSignInGoogle(.failure(.other(error))))
        }
      }
    }
  }

  var appleSignIn: () -> Effect<SignInReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.signInApple()
          await send(SignInReducer.Action.fetchSignInApple(.success(response)))
        } catch {
          await send(SignInReducer.Action.fetchSignInApple(.failure(.other(error))))
        }
      }
    }
  }

  var kakaoSignIn: () -> Effect<SignInReducer.Action> {
    {
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.signInKakao()
          await send(SignInReducer.Action.fetchSignInKakao(.success(response)))
        } catch {
          await send(SignInReducer.Action.fetchSignInKakao(.failure(.other(error))))
        }
      }
    }
  }

  var routeToSignUp: () -> Void {
    {
      navigator.next(
        linkItem: .init(
          path: Link.Dashboard.Path.signUp.rawValue,
          items: .none),
        isAnimated: true)
    }
  }

  var routeToProfile: () -> Void {
    {
      navigator.replace(
        linkItem: .init(
          path: Link.Dashboard.Path.profile.rawValue,
          items: .none),
        isAnimated: true)
    }
  }
}
