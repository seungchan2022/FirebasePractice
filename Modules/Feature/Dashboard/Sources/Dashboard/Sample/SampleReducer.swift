import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SampleReducer

@Reducer
struct SampleReducer {
  let sideEffect: SampleSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CanelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapNext:
        sideEffect.routeToNext()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

}

extension SampleReducer {
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

    case onTapNext

    case throwError(CompositeErrorRepository)

  }

}

// MARK: SampleReducer.CanelID

extension SampleReducer {
  enum CanelID: Equatable, CaseIterable {
    case teardown
  }
}
