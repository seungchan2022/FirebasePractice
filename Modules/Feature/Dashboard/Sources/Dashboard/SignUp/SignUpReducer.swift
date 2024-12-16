import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SignUpReducer

@Reducer
struct SignUpReducer {

  let sideEffect: SignUpSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapSignUp:
        state.fetchSignUp.isLoading = true
        return sideEffect
          .signUpEmail(.init(email: state.emailText, password: state.passwordText))
          .cancellable(pageID: state.id, id: CancelID.requestSignUp, cancelInFlight: true)

      case .fetchSignUp(let result):
        state.fetchSignUp.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "회원가입 성공")

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "회원가입 실패")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapBack:
        sideEffect.routeToBack()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }
}

extension SignUpReducer {

  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    var emailText = ""
    var passwordText = ""

    var isShowPassword = false

    var fetchSignUp: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapSignUp
    case fetchSignUp(Result<Bool, CompositeErrorRepository>)

    case onTapBack

    case throwError(CompositeErrorRepository)
  }
}

// MARK: SignUpReducer.CancelID

extension SignUpReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestSignUp
  }
}
