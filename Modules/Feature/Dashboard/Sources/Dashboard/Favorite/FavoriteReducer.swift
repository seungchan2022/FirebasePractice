import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - FavoriteReducer

@Reducer
struct FavoriteReducer {
  let sideEffect: FavoriteSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .throwError(let error):
        sideEffect.sideEffect.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

}

extension FavoriteReducer {

  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    init(id: UUID = .init()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case throwError(CompositeErrorRepository)
  }
}

// MARK: FavoriteReducer.CancelID

extension FavoriteReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown

  }
}
