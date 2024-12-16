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

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapBack

    case throwError(CompositeErrorRepository)
  }
}

// MARK: SignUpReducer.CancelID

extension SignUpReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
  }
}
