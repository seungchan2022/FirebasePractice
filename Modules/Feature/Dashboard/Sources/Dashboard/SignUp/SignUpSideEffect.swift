import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - SignUpSideEffect

struct SignUpSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension SignUpSideEffect {
  var signUpEmail: (AuthEntity.Email.Request) -> Effect<SignUpReducer.Action> {
    { req in
      .run { send in
        do {
          let response = try await useCaseGroup.authUseCase.signUpEmail(req)
          await send(SignUpReducer.Action.fetchSignUp(.success(response)))

        } catch {
          await send(SignUpReducer.Action.fetchSignUp(.failure(.other(error))))
        }
      }
    }
  }

  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }
}
