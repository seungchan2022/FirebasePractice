import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SignInReducer

@Reducer
struct SignInReducer {

  let sideEffect: SignInSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapSignIn:
        state.fetchSignIn.isLoading = true
        return sideEffect
          .signInEmail(.init(email: state.emailText, password: state.passwordText))
          .cancellable(pageID: state.id, id: CancelID.requestSignIn, cancelInFlight: true)

      case .fetchSignIn(let result):
        state.fetchSignIn.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "로그인 성공")
            sideEffect.routeToHome()

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "로그인 실패")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapSignUp:
        sideEffect.routeToSignUp()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

}

extension SignInReducer {

  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    var emailText = ""
    var passwordText = ""

    var isShowPassword = false

    var fetchSignIn: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapSignIn
    case fetchSignIn(Result<Bool, CompositeErrorRepository>)

    case onTapSignUp

    case throwError(CompositeErrorRepository)
  }
}

// MARK: SignInReducer.CancelID

extension SignInReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestSignIn
  }
}
